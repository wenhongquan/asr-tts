#pragma once

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QWebSocket>
#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>
#include <QTimer>

class AsrClient : public QObject {
    Q_OBJECT

public:
    explicit AsrClient(QObject* parent = nullptr);
    ~AsrClient();

    void connectToServer(const QString& host, quint16 port);
    void disconnectFromServer();
    void sendAudio(const QByteArray& audioData);
    void requestTranscribe();
    void clearBuffer();

    bool isConnected() const;

signals:
    void connected();
    void disconnected();
    void connectionError(const QString& error);
    void transcriptReceived(const QString& text, const QString& language);
    void serverInfoReceived(const QJsonObject& info);
    void cleared();

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString& message);
    void onError(QAbstractSocket::SocketError error);
    void onPingTimeout();

private:
    QWebSocket* m_webSocket;
    QString m_host;
    quint16 m_port;
    bool m_isConnected;
    QTimer* m_pingTimer;
};
