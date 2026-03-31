#pragma once

#include <QObject>
#include <QByteArray>

class AudioCapture : public QObject {
    Q_OBJECT

public:
    explicit AudioCapture(QObject* parent = nullptr);
    ~AudioCapture();

    bool start();
    void stop();
    bool isActive() const;

signals:
    void audioDataReady(const QByteArray& data);
    void audioLevelChanged(qreal level);
    void errorOccurred(const QString& error);

private:
    class Private;
    Private* m_private;
};
