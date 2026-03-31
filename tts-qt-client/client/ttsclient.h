#ifndef TTSCLIENT_H
#define TTSCLIENT_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QWebSocket>
#include <QJsonObject>

class TTSClient : public QObject
{
    Q_OBJECT

public:
    explicit TTSClient(QObject* parent = nullptr);
    ~TTSClient();

    void connectToServer(const QString& host, quint16 port);
    void disconnectFromServer();
    void synthesize(const QString& text, const QString& refAudio = QString(), int chunkIndex = -1);
    void requestVoices();
    bool isConnected() const;

Q_SIGNALS:
    void connected();
    void disconnected();
    void connectionError(const QString& error);
    void audioReceived(const QByteArray& audioData, int sampleRate, int chunkIndex, bool isFirst, bool isLast);
    void voicesReceived(const QStringList& voices);
    void synthesisFinished(int chunkIndex);
    void modelInfoReceived(const QJsonObject& info);

private Q_SLOTS:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString& message);
    void onError(QAbstractSocket::SocketError error);

private:
    QWebSocket* m_webSocket;
    bool m_isConnected;
};

#endif
