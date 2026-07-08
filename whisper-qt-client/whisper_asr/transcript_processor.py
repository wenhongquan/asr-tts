"""
Transcript Processor — deduplicates, stitches overlapping ASR windows,
detects utterance boundaries, and formats streaming output for the client.
"""

import time
from dataclasses import dataclass, field
from typing import Optional, List, Callable, Awaitable


@dataclass
class _Utterance:
    accumulated: str = ""
    last_raw: str = ""
    same_count: int = 0
    silence_since: float = 0.0


class TranscriptProcessor:
    """
    Processes streaming ASR transcripts into clean, segmented utterances.

    Each call to feed() returns a list of zero or more message dicts:
      {"type": "partial",   "text": "...", "seq": N}
      {"type": "utterance", "text": "...", "seq": N}
    """

    def __init__(
        self,
        silence_repeats: int = 3,
        silence_seconds: float = 3.0,
        post_hook: Optional[Callable[[str], Awaitable[str]]] = None,
    ):
        self.silence_repeats = silence_repeats
        self.silence_seconds = silence_seconds
        self._post_hook = post_hook

        self._current: Optional[_Utterance] = None
        self._global_seq = 0

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def feed(self, raw_text: str) -> List[dict]:
        """Feed a raw ASR transcript. Returns 0..N messages to send."""
        raw_text = raw_text.strip()
        if not raw_text:
            return []

        messages: List[dict] = []

        # ---- ensure we have an utterance context ----
        if self._current is None:
            self._current = _Utterance()

        # ---- 1. stitch ----
        if self._current.accumulated:
            merged, flush_msg = self._stitch(
                self._current.accumulated, raw_text
            )
            if flush_msg is not None:
                messages.append(flush_msg)
            # _stitch may have flushed (self._current = None). Restore.
            if self._current is None:
                self._current = _Utterance()
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
            self._current.last_raw = raw_text
            self._global_seq += 1
            messages.append({
                "type": "partial",
                "text": merged,
                "seq": self._global_seq,
            })

        # ---- 3. silence timer ----
        if (
            self._current.silence_since > 0
            and time.monotonic() - self._current.silence_since
            >= self.silence_seconds
        ):
            msg = self._flush()
            if msg:
                messages.append(msg)

        return messages

    def finalize(self) -> List[dict]:
        """Force-finalize (pause/end). Returns 0..1 messages."""
        return self._finish()

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    def _stitch(
        self, previous: str, next_text: str
    ) -> tuple[str, Optional[dict]]:
        """
        Merge next_text into previous using longest suffix–prefix overlap.
        Returns (merged_text, pending_utterance_message_or_None).
        The pending message contains the OLD utterance if there is no
        overlap with previous — i.e. the ASR has started a new utterance.
        """
        if not next_text:
            return previous, None
        if next_text.startswith(previous):
            return next_text, None

        # Longest suffix–prefix overlap
        for n in range(len(next_text), 0, -1):
            needle = next_text[:n]
            if previous.endswith(needle):
                return previous + next_text[n:], None

        # No overlap at all — previous utterance is finished.
        flush = self._flush()
        return next_text, flush

    def _flush(self) -> Optional[dict]:
        """Flush current utterance. Returns utterance message or None."""
        if self._current is None:
            return None
        text = self._current.accumulated.strip()
        self._current = None
        if not text:
            return None
        self._global_seq += 1
        return {"type": "utterance", "text": text, "seq": self._global_seq}

    def _finish(self) -> List[dict]:
        """Finalize and clean up. Returns 0..1 messages."""
        messages: List[dict] = []
        msg = self._flush()
        if msg:
            messages.append(msg)
        self._current = None
        return messages
