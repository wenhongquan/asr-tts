#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QString>
#include <QTimer>
#include <QProcess>
#include <QQueue>
#include <QMutex>
#include <QVector>
#include <QSet>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class TTSClient;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

private slots:
    void onConnectClicked();
    void onSynthesizeClicked();
    void onBrowseRefAudio();
    void onConnected();
    void onDisconnected();
    void onConnectionError(const QString& error);
    void onAudioReceived(const QByteArray& audioData, int sampleRate, int chunkIndex, bool isFirst, bool isLast);
    void onSynthesisFinished(int chunkIndex);
    void onVoicesReceived(const QStringList& voices);
    void onPlayerFinished();

private:
    Ui::MainWindow* ui;
    TTSClient* m_ttsClient;
    QProcess* m_playerProcess;
    bool m_isConnected;
    QString m_refAudio;
    QMap<QString, QByteArray> m_audioBuffer;
    QSet<QString> m_receivedChunkIds;
    QMap<int, bool> m_streamComplete;
    QMutex m_audioMutex;
    int m_totalChunks;
    int m_receivedChunks;
    int m_nextExpectedChunk;
    bool m_isPlaying;
    
    void updateUiState();
    void playNextInQueue();
    void playAudio(const QByteArray& wavData);
    QStringList splitTextIntoChunks(const QString& text, int chunkSize);
};

#endif
