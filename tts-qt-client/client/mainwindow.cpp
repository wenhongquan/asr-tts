#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "ttsclient.h"

#include <QMessageBox>
#include <QFile>
#include <QFileDialog>
#include <QDebug>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , m_ttsClient(nullptr)
    , m_playerProcess(nullptr)
    , m_isConnected(false)
    , m_totalChunks(0)
    , m_receivedChunks(0)
    , m_nextExpectedChunk(0)
    , m_isPlaying(false)
{
    ui->setupUi(this);

    m_ttsClient = new TTSClient(this);
    m_playerProcess = new QProcess(this);

    connect(ui->btnConnect, &QPushButton::clicked, this, &MainWindow::onConnectClicked);
    connect(ui->btnSynthesize, &QPushButton::clicked, this, &MainWindow::onSynthesizeClicked);
    connect(ui->btnBrowseRefAudio, &QPushButton::clicked, this, &MainWindow::onBrowseRefAudio);
    
    connect(m_playerProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, &MainWindow::onPlayerFinished);
    
    connect(ui->actionExit, &QAction::triggered, this, &QMainWindow::close);
    connect(ui->actionAbout, &QAction::triggered, this, [this]() {
        QMessageBox::about(this, "About", 
            "TTS Client v2.0 - Fast Concurrent TTS\n\n"
            "Enter text and click Synthesize");
    });

    connect(m_ttsClient, &TTSClient::connected, this, &MainWindow::onConnected);
    connect(m_ttsClient, &TTSClient::disconnected, this, &MainWindow::onDisconnected);
    connect(m_ttsClient, &TTSClient::connectionError, this, &MainWindow::onConnectionError);
    connect(m_ttsClient, &TTSClient::audioReceived, this, &MainWindow::onAudioReceived);
    connect(m_ttsClient, &TTSClient::synthesisFinished, this, &MainWindow::onSynthesisFinished);
    connect(m_ttsClient, &TTSClient::voicesReceived, this, &MainWindow::onVoicesReceived);

    ui->lineEditRefAudio->setText("/Users/wenhongquan/Downloads/zh.wav");
    m_refAudio = ui->lineEditRefAudio->text();

    updateUiState();

    QTimer::singleShot(500, this, [this]() {
        onConnectClicked();
    });
}

MainWindow::~MainWindow()
{
    if (m_isConnected) {
        m_ttsClient->disconnectFromServer();
    }
}

void MainWindow::onConnectClicked()
{
    if (m_isConnected) {
        m_ttsClient->disconnectFromServer();
        return;
    }

    QString host = ui->lineEditHost->text();
    quint16 port = ui->lineEditPort->text().toUShort();

    ui->labelStatus->setText("Connecting...");
    ui->btnConnect->setEnabled(false);
    
    m_ttsClient->connectToServer(host, port);
}

void MainWindow::onBrowseRefAudio()
{
    QString filePath = QFileDialog::getOpenFileName(
        this,
        "Select Reference Audio",
        "/Users/wenhongquan/Downloads",
        "Audio Files (*.wav *.mp3 *.flac);;All Files (*)"
    );
    
    if (!filePath.isEmpty()) {
        ui->lineEditRefAudio->setText(filePath);
        m_refAudio = filePath;
    }
}

QStringList MainWindow::splitTextIntoChunks(const QString& text, int chunkSize)
{
    QStringList chunks;
    QString delimiters = ",，。！？.!?\n";
    QString current;
    
    for (int i = 0; i < text.length(); i++) {
        QChar ch = text[i];
        current.append(ch);
        
        if (delimiters.contains(ch) && current.length() > 2) {
            chunks.append(current.trimmed());
            current.clear();
        } else if (current.length() >= chunkSize) {
            int lastSpace = current.lastIndexOf(' ');
            if (lastSpace > chunkSize / 2) {
                QString chunk = current.left(lastSpace).trimmed();
                if (!chunk.isEmpty()) chunks.append(chunk);
                current = current.mid(lastSpace + 1);
            } else {
                chunks.append(current.trimmed());
                current.clear();
            }
        }
    }
    
    if (!current.trimmed().isEmpty()) {
        chunks.append(current.trimmed());
    }
    
    return chunks;
}

void MainWindow::onSynthesizeClicked()
{
    QString text = ui->textEditInput->toPlainText().trimmed();
    if (text.isEmpty()) {
        QMessageBox::warning(this, "Warning", "Please enter text to synthesize");
        return;
    }

    m_refAudio = ui->lineEditRefAudio->text().trimmed();
    
    QStringList chunks = splitTextIntoChunks(text, 50);
    
    if (chunks.isEmpty()) {
        QMessageBox::warning(this, "Warning", "No valid chunks to synthesize");
        return;
    }
    
    m_audioBuffer.clear();
    m_receivedChunkIds.clear();
    m_streamComplete.clear();
    m_totalChunks = chunks.size();
    m_receivedChunks = 0;
    m_nextExpectedChunk = 0;
    m_isPlaying = false;
    
    ui->labelStatus->setText(QString("Sending %1 chunks...").arg(chunks.size()));
    ui->btnSynthesize->setEnabled(false);
    
    qDebug() << "Sending" << chunks.size() << "chunks";
    
    for (int i = 0; i < chunks.size(); i++) {
        m_ttsClient->synthesize(chunks[i], m_refAudio, i);
    }
}

void MainWindow::onConnected()
{
    m_isConnected = true;
    ui->labelStatus->setText("Connected");
    ui->btnConnect->setText("Disconnect");
    ui->btnConnect->setEnabled(true);
    updateUiState();
    
    m_ttsClient->requestVoices();
}

void MainWindow::onDisconnected()
{
    m_isConnected = false;
    ui->labelStatus->setText("Disconnected");
    ui->btnConnect->setText("Connect");
    ui->btnConnect->setEnabled(true);
    updateUiState();
    
    m_audioBuffer.clear();
    m_receivedChunkIds.clear();
    m_streamComplete.clear();
    m_isPlaying = false;
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

void MainWindow::onAudioReceived(const QByteArray& audioData, int sampleRate, int chunkIndex, bool isFirst, bool isLast)
{
    Q_UNUSED(sampleRate);
    qDebug() << "Received chunk" << chunkIndex << ":" << audioData.size() 
             << "bytes (first=" << isFirst << ", last=" << isLast << ")";
    
    m_audioMutex.lock();
    
    QString key = QString("%1_%2").arg(chunkIndex).arg(isFirst ? "first" : "sub");
    if (m_receivedChunkIds.contains(key)) {
        qDebug() << "Duplicate chunk" << key << "- ignored";
        m_audioMutex.unlock();
        return;
    }
    m_receivedChunkIds.insert(key);
    
    QString chunkKey = QString::number(chunkIndex);
    if (!m_audioBuffer.contains(chunkKey)) {
        m_audioBuffer[chunkKey] = audioData;
        if (isFirst) {
            m_receivedChunks++;
            ui->labelStatus->setText(QString("Received %1/%2 streams").arg(m_receivedChunks).arg(m_totalChunks));
        }
    } else {
        m_audioBuffer[chunkKey].append(audioData);
    }
    
    if (isLast) {
        m_streamComplete[chunkIndex] = true;
    }
    
    m_audioMutex.unlock();
    
    playNextInQueue();
}

void MainWindow::onSynthesisFinished(int chunkIndex)
{
    qDebug() << "Chunk" << chunkIndex << "finished";
}

void MainWindow::onVoicesReceived(const QStringList& voices)
{
    qDebug() << "Available voices:" << voices;
}

void MainWindow::onPlayerFinished()
{
    m_isPlaying = false;
    playNextInQueue();
}

void MainWindow::playNextInQueue()
{
    m_audioMutex.lock();
    
    if (m_isPlaying) {
        m_audioMutex.unlock();
        return;
    }
    
    QString key = QString::number(m_nextExpectedChunk);
    if (m_audioBuffer.contains(key) && m_streamComplete.value(m_nextExpectedChunk, false)) {
        QByteArray audio = m_audioBuffer.take(key);
        m_streamComplete.remove(m_nextExpectedChunk);
        m_isPlaying = true;
        m_nextExpectedChunk++;
        
        m_audioMutex.unlock();
        
        playAudio(audio);
    } else {
        m_audioMutex.unlock();
        
        if (m_receivedChunks == m_totalChunks && m_totalChunks > 0) {
            ui->btnSynthesize->setEnabled(true);
            ui->labelStatus->setText("Ready");
        }
    }
}

void MainWindow::playAudio(const QByteArray& wavData)
{
    if (wavData.isEmpty()) {
        playNextInQueue();
        return;
    }

    QString tempPath = QDir::temp().filePath(QString("tts_%1.wav").arg(QDateTime::currentMSecsSinceEpoch()));
    QFile file(tempPath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(wavData);
        file.close();
        
        m_playerProcess->start("afplay", QStringList() << tempPath);
        qDebug() << "Playing:" << tempPath;
    } else {
        qWarning() << "Failed to save WAV file";
        playNextInQueue();
    }
}

void MainWindow::updateUiState()
{
    ui->lineEditHost->setEnabled(!m_isConnected);
    ui->lineEditPort->setEnabled(!m_isConnected);
    ui->btnSynthesize->setEnabled(m_isConnected);
}
