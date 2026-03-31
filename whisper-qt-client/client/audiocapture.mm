#import <AVFoundation/AVFoundation.h>
#include "audiocapture.h"
#include <QDebug>
#include <QCoreApplication>
#include <cmath>

// Target sample rate for ASR
static const int TARGET_SAMPLE_RATE = 16000;

class AudioCapture::Private : public QObject {
    Q_OBJECT
public:
    Private(QObject* parent = nullptr) : QObject(parent), m_audioEngine(nil), m_isRecording(false), m_actualSampleRate(44100) {}
    ~Private() { stopRecording(); }
    
    // Simple linear interpolation resampling
    QByteArray resample(const float* input, int inputCount, int inputRate, int outputRate) {
        if (inputRate == outputRate) {
            QByteArray result(inputCount * sizeof(int16_t), 0);
            int16_t* out = (int16_t*)result.data();
            for (int i = 0; i < inputCount; i++) {
                float s = fmaxf(-1.0f, fminf(1.0f, input[i]));
                out[i] = (int16_t)(s * 32767.0f);
            }
            return result;
        }
        
        double ratio = (double)outputRate / inputRate;
        int outputCount = (int)(inputCount * ratio);
        
        QByteArray result(outputCount * sizeof(int16_t), 0);
        int16_t* out = (int16_t*)result.data();
        
        for (int i = 0; i < outputCount; i++) {
            double srcIndex = i / ratio;
            int srcIdx = (int)srcIndex;
            double frac = srcIndex - srcIdx;
            
            float s1 = (srcIdx < inputCount) ? input[srcIdx] : 0.0f;
            float s2 = (srcIdx + 1 < inputCount) ? input[srcIdx + 1] : s1;
            float s = s1 + (s2 - s1) * frac;
            
            s = fmaxf(-1.0f, fminf(1.0f, s));
            out[i] = (int16_t)(s * 32767.0f);
        }
        
        return result;
    }
    
    bool startRecording() {
        if (m_isRecording) return true;
        
        m_audioEngine = [[AVAudioEngine alloc] init];
        AVAudioInputNode* inputNode = [m_audioEngine inputNode];
        AVAudioFormat* recordingFormat = [inputNode inputFormatForBus:0];
        
        m_actualSampleRate = (int)recordingFormat.sampleRate;
        
        qDebug() << "Input format - sample rate:" << m_actualSampleRate 
                 << "channel count:" << recordingFormat.channelCount;
        qDebug() << "Will resample from" << m_actualSampleRate << "to" << TARGET_SAMPLE_RATE;
        
        __weak QObject* weakParent = this;
        
        [inputNode installTapOnBus:0 bufferSize:4096 format:recordingFormat block:^(AVAudioPCMBuffer* buffer, AVAudioTime* when) {
            if (!buffer || buffer.frameLength == 0) return;
            
            float* samples = buffer.floatChannelData[0];
            int numSamples = buffer.frameLength;
            
            // Resample to target rate
            QByteArray audioData = resample(samples, numSamples, m_actualSampleRate, TARGET_SAMPLE_RATE);
            
            QMetaObject::invokeMethod(weakParent, "handleAudioData", Qt::QueuedConnection, Q_ARG(QByteArray, audioData));
        }];
        
        NSError* error = nil;
        [m_audioEngine prepare];
        [m_audioEngine startAndReturnError:&error];
        
        if (error) {
            qWarning() << "Failed to start audio engine:" << error.localizedDescription.UTF8String;
            return false;
        }
        
        m_isRecording = true;
        qDebug() << "Audio recording started (resampling to 16kHz)";
        return true;
    }
    
    void stopRecording() {
        if (!m_isRecording) return;
        
        if (m_audioEngine) {
            [[m_audioEngine inputNode] removeTapOnBus:0];
            [m_audioEngine stop];
            m_audioEngine = nil;
        }
        
        m_isRecording = false;
        qDebug() << "Audio recording stopped";
    }
    
    bool isRecording() const { return m_isRecording; }
    
public slots:
    void handleAudioData(const QByteArray& data) {
        float sum = 0.0f;
        const int16_t* samples = (const int16_t*)data.constData();
        int numSamples = data.size() / sizeof(int16_t);
        
        for (int i = 0; i < numSamples; i++) {
            float s = fabsf(samples[i] / 32768.0f);
            sum += s * s;
        }
        float rms = sqrtf(sum / numSamples);
        float level = qBound(0.0f, rms * 2.0f, 1.0f);
        
        emit audioLevelChanged(level);
        emit audioDataReady(data);
    }
    
signals:
    void audioDataReady(const QByteArray& data);
    void audioLevelChanged(qreal level);
    
private:
    AVAudioEngine* m_audioEngine;
    bool m_isRecording;
    int m_actualSampleRate;
};

AudioCapture::AudioCapture(QObject* parent)
    : QObject(parent)
    , m_private(new Private(this))
{
    qDebug() << "AudioCapture created";
    
    connect(m_private, &Private::audioDataReady, this, &AudioCapture::audioDataReady);
    connect(m_private, &Private::audioLevelChanged, this, &AudioCapture::audioLevelChanged);
}

AudioCapture::~AudioCapture()
{
    stop();
}

bool AudioCapture::start()
{
    qDebug() << "AudioCapture::start()";
    return m_private->startRecording();
}

void AudioCapture::stop()
{
    qDebug() << "AudioCapture::stop()";
    m_private->stopRecording();
}

bool AudioCapture::isActive() const
{
    return m_private->isRecording();
}

#include "audiocapture.moc"
