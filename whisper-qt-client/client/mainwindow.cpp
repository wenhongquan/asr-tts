#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "audiocapture.h"
#include "asrclient.h"

#include <QMessageBox>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QAudioDevice>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , m_audioCapture(nullptr)
    , m_asrClient(nullptr)
    , m_isRecording(false)
    , m_isConnected(false)
    , m_transcribeTimer(nullptr)
{
    ui->setupUi(this);

    m_audioCapture = new AudioCapture(this);
    m_asrClient = new AsrClient(this);
    m_transcribeTimer = new QTimer(this);

    connect(ui->btnConnect, &QPushButton::clicked, this, &MainWindow::onConnectClicked);
    connect(ui->btnStartStop, &QPushButton::clicked, this, &MainWindow::onStartStopClicked);
    connect(ui->btnClear, &QPushButton::clicked, this, &MainWindow::onClearClicked);
    connect(ui->actionExit, &QAction::triggered, this, &QMainWindow::close);
    connect(ui->actionAbout, &QAction::triggered, this, [this]() {
        QMessageBox::about(this, "About", 
            "Whisper ASR Client v1.0\n\n"
            "Real-time speech recognition using faster-whisper.\n\n"
            "Start the ASR server first:\n"
            "  python -m whisper_asr.server --model small");
    });

    connect(m_asrClient, &AsrClient::connected, this, &MainWindow::onConnected);
    connect(m_asrClient, &AsrClient::disconnected, this, &MainWindow::onDisconnected);
    connect(m_asrClient, &AsrClient::connectionError, this, &MainWindow::onConnectionError);
    connect(m_asrClient, &AsrClient::transcriptReceived, this, &MainWindow::onTranscriptReceived);

    connect(m_audioCapture, &AudioCapture::audioDataReady, this, &MainWindow::onAudioDataReady);
    connect(m_audioCapture, &AudioCapture::audioLevelChanged, this, &MainWindow::onAudioLevelChanged);
    connect(m_audioCapture, &AudioCapture::errorOccurred, this, [this](const QString& error) {
        QMessageBox::warning(this, "Audio Error", error);
    });

    connect(m_transcribeTimer, &QTimer::timeout, this, [this]() {
        if (m_isRecording && m_asrClient->isConnected()) {
            m_asrClient->requestTranscribe();
        }
    });

    updateUiState();
    
    // Auto-connect on startup
    QTimer::singleShot(500, this, [this]() {
        onConnectClicked();
    });
    
    // Auto-start recording after connect
    QTimer::singleShot(1500, this, [this]() {
        if (m_isConnected) {
            onStartStopClicked();
        }
    });
}

MainWindow::~MainWindow()
{
    if (m_isRecording) {
        m_audioCapture->stop();
    }
    if (m_isConnected) {
        m_asrClient->disconnectFromServer();
    }
}

void MainWindow::onConnectClicked()
{
    if (m_isConnected) {
        m_asrClient->disconnectFromServer();
        return;
    }

    QString host = ui->lineEditHost->text();
    quint16 port = ui->lineEditPort->text().toUShort();

    ui->labelStatus->setText("Connecting...");
    ui->btnConnect->setEnabled(false);
    
    m_asrClient->connectToServer(host, port);
}

void MainWindow::onStartStopClicked()
{
    if (m_isRecording) {
        m_audioCapture->stop();
        m_transcribeTimer->stop();
        m_isRecording = false;
        ui->btnStartStop->setText("Start Recording");
        
        if (m_isConnected) {
            m_asrClient->requestTranscribe();
        }
    } else {
        if (m_audioCapture->start()) {
            m_isRecording = true;
            ui->btnStartStop->setText("Stop Recording");
            m_transcribeTimer->start(2000);
        }
    }
    
    updateUiState();
}

void MainWindow::onClearClicked()
{
    ui->textEditTranscript->clear();
    
    if (m_isConnected) {
        m_asrClient->clearBuffer();
    }
}

void MainWindow::onConnected()
{
    m_isConnected = true;
    ui->labelStatus->setText("Connected");
    ui->btnConnect->setText("Disconnect");
    ui->btnConnect->setEnabled(true);
    updateUiState();
}

void MainWindow::onDisconnected()
{
    m_isConnected = false;
    ui->labelStatus->setText("Disconnected");
    ui->btnConnect->setText("Connect");
    ui->btnConnect->setEnabled(true);
    
    if (m_isRecording) {
        m_audioCapture->stop();
        m_transcribeTimer->stop();
        m_isRecording = false;
        ui->btnStartStop->setText("Start Recording");
    }
    
    updateUiState();
}

void MainWindow::onConnectionError(const QString& error)
{
    m_isConnected = false;
    ui->labelStatus->setText("Connection Error");
    ui->btnConnect->setText("Connect");
    ui->btnConnect->setEnabled(true);
    QMessageBox::warning(this, "Connection Error", error);
    updateUiState();
}

void MainWindow::onTranscriptReceived(const QString& text, const QString& language)
{
    if (!text.isEmpty()) {
        appendTranscript(text);
    }
}

void MainWindow::onAudioLevelChanged(qreal level)
{
    int percent = static_cast<int>(level * 100);
    ui->labelAudioLevel->setText(QString("Audio Level: %1%").arg(percent));
}

void MainWindow::onAudioDataReady(const QByteArray& data)
{
    qDebug() << "onAudioDataReady: data size =" << data.size();
    if (m_isConnected) {
        qDebug() << "Sending audio to server...";
        m_asrClient->sendAudio(data);
    }
}

void MainWindow::updateUiState()
{
    ui->lineEditHost->setEnabled(!m_isConnected);
    ui->lineEditPort->setEnabled(!m_isConnected);
    ui->btnStartStop->setEnabled(m_isConnected);
}

void MainWindow::appendTranscript(const QString& text)
{
    QString timestamp = QDateTime::currentDateTime().toString("HH:mm:ss");
    ui->textEditTranscript->append(QString("[%1] %2").arg(timestamp).arg(text));
    
    QTextCursor cursor = ui->textEditTranscript->textCursor();
    cursor.movePosition(QTextCursor::End);
    ui->textEditTranscript->setTextCursor(cursor);
}
