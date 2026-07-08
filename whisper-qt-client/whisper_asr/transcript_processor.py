"""
Transcript Processor — deduplicates, stitches overlapping ASR windows,
detects utterance boundaries, and formats streaming output for the client.

Flow:
  raw ASR transcript (sliding window, every ~2 s)
      │
      ▼
  _stitch() — overlap-merge with accumulated buffer
      │
      ▼
  _detect_boundary() — same text repeated = silence = utterance end
      │
      ├── partial → {"type": "partial", "text": accumulated, "seq": N}
      │
      └── (after 3× same text + 3 s silence)
          utterance → {"type": "utterance", "text": full, "seq": N}
"""

import time
from dataclasses import dataclass, field
from typing import Optional, Callable, Awaitable


@dataclass
class _Utterance:
    """Tracks a single utterance being built."""
    accumulated: str = ""
    last_raw: str = ""
    same_count: int = 0
    silence_since: float = 0.0
    finalized: bool = False
    seq: int = 0  # monotonic counter for this utterance


class TranscriptProcessor:
    """
    Processes streaming ASR transcripts into clean, segmented utterances.

    Pipeline (extensible):
      1. stitch   — overlap-based deduplication
      2. boundary — silence-based utterance segmentation
      3. post     — (future) LLM-based punctuation/correction
    """

    def __init__(
        self,
        silence_repeats: int = 3,    # same-raw-text count before silence kicks in
        silence_seconds: float = 3.0,  # timer after silence detection
        post_hook: Optional[Callable[[str], Awaitable[str]]] = None,
    ):
        self.silence_repeats = silence_repeats
        self.silence_seconds = silence_seconds
        self._post_hook = post_hook  # LLM correction hook (future)

        self._current: Optional[_Utterance] = None
        self._global_seq = 0

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def feed(self, raw_text: str) -> dict | None:
        """
        Feed a raw ASR transcript. Returns a message dict to send to the
        client, or None if nothing should be sent this tick.

        Message shapes:
          {"type": "partial",   "text": "...", "seq": N}
          {"type": "utterance", "text": "...", "seq": N}
        """
        raw_text = raw_text.strip()
        self._ensure_utterance()

        # ---- 1. stitch ----
        if self._current.accumulated:
            merged = self._stitch(self._current.accumulated, raw_text)
        else:
            merged = raw_text

        self._current.accumulated = merged

        # ---- 2. boundary detection ----
        if raw_text == self._current.last_raw:
            self._current.same_count += 1
            if self._current.same_count >= self.silence_repeats:
                if self._current.silence_since == 0.0:
                    self._current.silence_since = time.monotonic()
        else:
            self._current.same_count = 0
            self._current.silence_since = 0.0
            self._global_seq += 1
            self._current.last_raw = raw_text
            return {"type": "partial", "text": merged, "seq": self._global_seq}

        # ---- 3. silence timer ----
        if (
            self._current.silence_since > 0
            and time.monotonic() - self._current.silence_since >= self.silence_seconds
        ):
            return self._finalize()

        return None

    def finalize(self) -> dict | None:
        """Force-finalize the current utterance (e.g. on pause/end)."""
        self._ensure_utterance()
        return self._finalize()

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    def _ensure_utterance(self):
        if self._current is None:
            self._current = _Utterance(seq=self._global_seq)

    def _stitch(self, previous: str, next_text: str) -> str:
        """
        Stitch two overlapping transcripts by finding the longest suffix of
        *previous* that matches a prefix of *next_text*, then appending only
        the non-overlapping suffix. If there is no overlap, *next_text* is a
        fresh utterance — finalize current and return *next_text* alone.
        """
        if not next_text:
            return previous
        if next_text.startswith(previous):
            return next_text

        # Longest suffix–prefix overlap
        for n in range(len(next_text), 0, -1):
            needle = next_text[:n]
            if previous.endswith(needle):
                return previous + next_text[n:]

        # No overlap → new utterance
        self._finalize()
        self._current = _Utterance(seq=self._global_seq)
        return next_text

    def _finalize(self) -> dict | None:
        """Finalize current utterance and return the utterance message."""
        if self._current is None:
            return None
        text = self._current.accumulated.strip()
        self._current = None
        self._global_seq += 1
        if not text:
            return None
        return {"type": "utterance", "text": text, "seq": self._global_seq}
