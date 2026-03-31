#include "asrclient.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QByteArray>
#include <QDebug>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QBuffer>

AsrClient::AsrClient(QObject* parent)
    : QObject(parent)
    , m_webSocket(nullptr)
    , m_isConnected(false)
    , m_pingTimer(nullptr)
{
    m_webSocket = new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this);
    
    connect(m_webSocket, &QWebSocket::connected, this, &AsrClient::onConnected);
    connect(m_webSocket, &QWebSocket::disconnected, this, &AsrClient::onDisconnected);
    connect(m_webSocket, &QWebSocket::textMessageReceived, this, &AsrClient::onTextMessageReceived);
    connect(m_webSocket, &QWebSocket::errorOccurred, this, &AsrClient::onError);
    
    m_pingTimer = new QTimer(this);
    connect(m_pingTimer, &QTimer::timeout, this, &AsrClient::onPingTimeout);
}

AsrClient::~AsrClient()
{
    disconnectFromServer();
}

void AsrClient::connectToServer(const QString& host, quint16 port)
{
    if (m_isConnected) {
        disconnectFromServer();
        return;
    }
    
    m_host = host;
    m_port = port;
    
    QString url = QString("ws://%1:%2").arg(host).arg(port);
    qDebug() << "Connecting to" << url;
    
    m_webSocket->open(QUrl(url));
}

void AsrClient::disconnectFromServer()
{
    if (m_pingTimer->isActive()) {
        m_pingTimer->stop();
    }
    
    if (m_webSocket) {
        m_webSocket->close();
    }
    
    m_isConnected = false;
}

void AsrClient::sendAudio(const QByteArray& audioData)
{
    if (!m_isConnected) {
        return;
    }
    
    QString base64Data = audioData.toBase64();
    
    QJsonObject message;
    message["type"] = "audio";
    message["data"] = base64Data;
    
    QJsonDocument doc(message);
    m_webSocket->sendTextMessage(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
}

void AsrClient::requestTranscribe()
{
    if (!m_isConnected) {
        return;
    }
    
    QJsonObject message;
    message["type"] = "transcribe";
    
    QJsonDocument doc(message);
    m_webSocket->sendTextMessage(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
}

void AsrClient::clearBuffer()
{
    if (!m_isConnected) {
        return;
    }
    
    QJsonObject message;
    message["type"] = "clear";
    
    QJsonDocument doc(message);
    m_webSocket->sendTextMessage(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
}

bool AsrClient::isConnected() const
{
    return m_isConnected;
}

void AsrClient::onConnected()
{
    qDebug() << "WebSocket connected";
    m_isConnected = true;
    m_pingTimer->start(30000);
    emit connected();
}

void AsrClient::onDisconnected()
{
    qDebug() << "WebSocket disconnected";
    m_isConnected = false;
    m_pingTimer->stop();
    emit disconnected();
}

void AsrClient::onTextMessageReceived(const QString& message)
{
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());
    if (!doc.isObject()) {
        return;
    }
    
    QJsonObject obj = doc.object();
    QString type = obj["type"].toString();
    
    if (type == "connected") {
        QJsonObject info = obj["model"].toObject();
        emit serverInfoReceived(info);
    }
    else if (type == "transcript") {
        QString text = obj["text"].toString();
        QString language = obj["language"].toString();
        emit transcriptReceived(text, language);
    }
    else if (type == "error") {
        QString errorMsg = obj["message"].toString();
        emit connectionError(errorMsg);
    }
    else if (type == "cleared") {
        emit cleared();
    }
}

void AsrClient::onError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error)
    QString errorString = m_webSocket->errorString();
    qWarning() << "WebSocket error:" << errorString;
    m_isConnected = false;
    emit connectionError(errorString);
}

void AsrClient::onPingTimeout()
{
    if (m_isConnected) {
        m_webSocket->ping();
    }
}
