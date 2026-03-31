#include "ttsclient.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QUrl>

TTSClient::TTSClient(QObject* parent)
    : QObject(parent)
    , m_webSocket(nullptr)
    , m_isConnected(false)
{
    m_webSocket = new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this);
    
    connect(m_webSocket, &QWebSocket::connected, this, &TTSClient::onConnected);
    connect(m_webSocket, &QWebSocket::disconnected, this, &TTSClient::onDisconnected);
    connect(m_webSocket, &QWebSocket::textMessageReceived, this, &TTSClient::onTextMessageReceived);
    connect(m_webSocket, &QWebSocket::errorOccurred, this, &TTSClient::onError);
}

TTSClient::~TTSClient()
{
    disconnectFromServer();
}

void TTSClient::connectToServer(const QString& host, quint16 port)
{
    if (m_isConnected) {
        disconnectFromServer();
        return;
    }
    
    QString url = QString("ws://%1:%2").arg(host).arg(port);
    qDebug() << "Connecting to" << url;
    
    m_webSocket->open(QUrl(url));
}

void TTSClient::disconnectFromServer()
{
    if (m_webSocket) {
        m_webSocket->close();
    }
    m_isConnected = false;
}

void TTSClient::synthesize(const QString& text, const QString& refAudio, int chunkIndex)
{
    if (!m_isConnected) {
        qWarning() << "Not connected to server";
        return;
    }
    
    QJsonObject message;
    message["type"] = "synthesize";
    message["text"] = text;
    message["chunk_index"] = chunkIndex;
    if (!refAudio.isEmpty()) {
        message["ref_audio"] = refAudio;
    }
    
    QJsonDocument doc(message);
    m_webSocket->sendTextMessage(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    
    qDebug() << "Sent chunk" << chunkIndex << ":" << text;
}

void TTSClient::requestVoices()
{
    if (!m_isConnected) {
        return;
    }
    
    QJsonObject message;
    message["type"] = "voices";
    
    QJsonDocument doc(message);
    m_webSocket->sendTextMessage(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
}

bool TTSClient::isConnected() const
{
    return m_isConnected;
}

void TTSClient::onConnected()
{
    qDebug() << "WebSocket connected";
    m_isConnected = true;
    emit connected();
}

void TTSClient::onDisconnected()
{
    qDebug() << "WebSocket disconnected";
    m_isConnected = false;
    emit disconnected();
}

void TTSClient::onTextMessageReceived(const QString& message)
{
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());
    if (!doc.isObject()) {
        return;
    }
    
    QJsonObject obj = doc.object();
    QString type = obj["type"].toString();
    
    if (type == "connected") {
        QJsonObject info = obj["model"].toObject();
        emit modelInfoReceived(info);
    }
    else if (type == "audio") {
        QString audioBase64 = obj["data"].toString();
        int sampleRate = obj["sample_rate"].toInt(24000);
        int chunkIndex = obj["chunk_index"].toInt(-1);
        bool isFirst = obj["is_first"].toBool(false);
        bool isLast = obj["is_last"].toBool(false);
        
        QByteArray audioData = QByteArray::fromBase64(audioBase64.toUtf8());
        qDebug() << "Received chunk" << chunkIndex << ":" << audioData.size() 
                 << "bytes (first=" << isFirst << ", last=" << isLast << ")";
        
        emit audioReceived(audioData, sampleRate, chunkIndex, isFirst, isLast);
        if (isLast) {
            emit synthesisFinished(chunkIndex);
        }
    }
    else if (type == "voices") {
        QJsonArray voicesArray = obj["voices"].toArray();
        QStringList voices;
        for (const QJsonValue& v : voicesArray) {
            voices.append(v.toString());
        }
        emit voicesReceived(voices);
    }
    else if (type == "error") {
        QString errorMsg = obj["message"].toString();
        int chunkIndex = obj["chunk_index"].toInt(-1);
        qWarning() << "Server error for chunk" << chunkIndex << ":" << errorMsg;
        emit synthesisFinished(chunkIndex);
    }
}

void TTSClient::onError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error)
    QString errorString = m_webSocket->errorString();
    qWarning() << "WebSocket error:" << errorString;
    m_isConnected = false;
    emit connectionError(errorString);
}
