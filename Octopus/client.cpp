#include "client.h"
#include <QUrl>
#include <QBuffer>


Client::Client(QObject *parent) : QObject(parent)
{
    _ws = new QWebSocket();
    connect(_ws, &QWebSocket::disconnected,this, &Client::disConnected,Qt::AutoConnection);
    connect(_ws, &QWebSocket::textMessageReceived,this, &Client::textReceived,Qt::AutoConnection);
    connect(_ws, &QWebSocket::binaryMessageReceived,this, &Client::dataReceived,Qt::AutoConnection);
    connect(_ws, &QWebSocket::connected, this, &Client::connected,Qt::AutoConnection);
    connect(_ws, &QWebSocket::pong, this, &Client::pong,Qt::AutoConnection);

    _heartbeatTimer = new QTimer(this);
    connect(_heartbeatTimer, SIGNAL(timeout()), this, SLOT(heartbeat()));
    _heartbeatTimer->start(5000);
}
Client::~Client() {
    close();
    if (_ws) {
        _ws->abort();
        delete  _ws;
    }
    if (_heartbeatTimer) {
        _heartbeatTimer->stop();
        delete _heartbeatTimer;
    }
}

QUrl Client::url() {
    return _url;
}

void Client::setUrl(QUrl url) {
    _url = url;
    emit urlChanged(url);
}

void Client::sendText(const QString& text) {
    if (_ws != nullptr) {
        _ws->sendBinaryMessage(text.toUtf8());
    }
}

void Client::sendFileWithPrefix(const QString& text, const QString& filePath) {
    if (_ws != nullptr) {
        QFile file(filePath);
        file.open(QIODevice::ReadOnly);
        QByteArray array = file.readAll();
        array.insert(0, text);

        _ws->sendBinaryMessage(array);
    }
}

void Client::open() {
    close();
    _ws->open(_url);
}

void Client::close() {
    if (_ws) {
        _ws->abort();
    }
}

void Client::heartbeat() {
    if (_ws != nullptr && _ws->isValid()) {
        _ws->ping();
    }
}

#include "ImageManager.h"
#include <QJsonParseError>

void Client::dataReceived(const QByteArray &message) {
    int index = message.indexOf('}');

    QByteArray header(message.data(), index + 1);

    QJsonParseError json_error;
    QJsonDocument jsonDoc(QJsonDocument::fromJson(header, &json_error));

    int contentSize = jsonDoc["size"].toInt();

    QByteArray content(message.data()+index + 1, contentSize);
    QJsonDocument jsonDoc1(QJsonDocument::fromJson(content, &json_error));


    QString filePath = jsonDoc1["FileName"].toString();

    int offset = index + 1 + contentSize;
    QByteArray body(message.data()+offset, message.length() - offset);

    filePath = ImageManager::saveFile(filePath, body);

    emit fileReceived(QByteArray(message.data(), offset), filePath);
}

QString Client::cachedFilePath(const QString& filePath) {
    return ImageManager::cached(filePath);
}

QString Client::cacheFile(const QString& filePath) {
    return ImageManager::cacheFile(filePath);
}

QQmlApplicationEngine* Client::engine;

void Client::viewImage(const QString& filePath) {
    QQmlComponent component(engine, QUrl("qrc:/qml/ImageViewer.qml"));
    QObject *temp_obj = component.create ();
    MyQuickWin* window = qobject_cast<MyQuickWin*>(temp_obj);

    window->setProperty("source", filePath);
}

#include <QFileInfo>
qint64 Client::sizeofFile(const QUrl& url) {

    QFileInfo info(url.toLocalFile());
    qint64 size = info.size();
    return size;
}

QString Client::base64encode(const QString& content) {
    return content.toUtf8().toBase64();
}
QString Client::base64decode(const QString& content) {
    QByteArray arr = content.toUtf8();
    QByteArray dec = QByteArray::fromBase64(arr);

    return QString(dec);
}

#include "MyImage.h"
QString Client::randomAvatar(const QString& text) {
    return MyImage::randomAvatar(text);
}

#include <QTranslator>
#include <QGuiApplication>

static QString language;

void Client::setLanguageStatic(const QString &lan) {

    ::language = lan;
    QTranslator translator;
    translator.load(":/" + lan + ".qm");
    QGuiApplication::instance()->installTranslator(&translator);
    engine->retranslate();
}

QString Client::language() {
    return ::language;
}
