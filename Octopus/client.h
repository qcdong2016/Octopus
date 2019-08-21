#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QUrl>
#include <QWebSocket>
#include <QTimer>
#include <QQuickTextDocument>
#include <QQmlApplicationEngine>

#include <QQuickWindow>

#include "http.h"

class MyQuickWin : public QQuickWindow {
    Q_OBJECT
public:
    void closeEvent(QCloseEvent *event)
    {
        deleteLater();
    }


    virtual void  hideEvent(QHideEvent *ev) {
        deleteLater();
    }
};


class Client : public QObject
{
    Q_OBJECT
public:
    explicit Client(QObject *parent = nullptr);
    ~Client();

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage)

    QUrl url();

signals:
    void languageChanged(QString url);
    void urlChanged(QUrl url);
    void connected();
    void disConnected();
    void pong(quint64 elapsedTime, const QByteArray &payload);
    void fileReceived(const QString& message, const QString& filePath);
    void textReceived(const QString& message);

public slots:
    void setUrl(QUrl url);

public:
    Q_INVOKABLE void sendFileWithPrefix(const QString& text, const QString& filePath);
    Q_INVOKABLE void sendText(const QString& text);
    Q_INVOKABLE void open();
    Q_INVOKABLE void close();
    Q_INVOKABLE QString cachedFilePath(const QString& filePath);
    Q_INVOKABLE QString cacheFile(const QString& filePath);
    Q_INVOKABLE void viewImage(const QString& filePath);
    Q_INVOKABLE qint64 sizeofFile(const QUrl& filePath);
    Q_INVOKABLE QString base64encode(const QString& content);
    Q_INVOKABLE QString base64decode(const QString& content);
    Q_INVOKABLE QString randomAvatar(const QString& text);
    Q_INVOKABLE static void setLanguageStatic(const QString& lan);
    Q_INVOKABLE static bool exists(const QUrl& filePath);
    Q_INVOKABLE static bool isDir(const QUrl& filePath);

    void setLanguage(QString lan) { setLanguageStatic(lan); }
    QString language();

    static QQmlApplicationEngine* engine;

private slots:
    void heartbeat();
    void dataReceived(const QByteArray &message);

private:
    QUrl _url;
    QWebSocket* _ws;
    QTimer* _heartbeatTimer;
};

#endif // CLIENT_H
