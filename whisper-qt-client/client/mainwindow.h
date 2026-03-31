#pragma once

#include <QMainWindow>
#include <QTimer>
#include <QAudioInput>
#include <QAudioSource>
#include <QByteArray>
#include <QTextEdit>
#include <QLineEdit>
#include <QPushButton>
#include <QLabel>

QT_BEGIN_NAMESPACE

namespace Ui {
class MainWindow;
}

QT_END_NAMESPACE

class AudioCapture;
class AsrClient;

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

private slots:
    void onConnectClicked();
    void onStartStopClicked();
    void onClearClicked();
    void onConnected();
    void onDisconnected();
    void onConnectionError(const QString& error);
    void onTranscriptReceived(const QString& text, const QString& language);
    void onAudioLevelChanged(qreal level);
    void onAudioDataReady(const QByteArray& data);

private:
    Ui::MainWindow* ui;
    AudioCapture* m_audioCapture;
    AsrClient* m_asrClient;
    bool m_isRecording;
    bool m_isConnected;
    QTimer* m_transcribeTimer;

    void updateUiState();
    void appendTranscript(const QString& text);
};
