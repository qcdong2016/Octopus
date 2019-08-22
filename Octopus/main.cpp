#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtGui>
#include <QtQml>
#include <QQuickItem>

#include "qmleventfilter.h"
#include "myimage.h"
#include "client.h"
#include "filesavedialog.h"


int main(int argc, char *argv[])
{
    srand((unsigned)time(NULL));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    app.setOrganizationName("Octopus");
    app.setOrganizationDomain("Octopus");
    app.setApplicationName("Octopus");

    QQmlApplicationEngine engine;
    Client::engine = &engine;

    Client::setLanguageStatic("zh_CN");

    qmlRegisterType<Http>("MyPlugins", 1, 0, "Http");
    qmlRegisterType<MyImage>("MyPlugins", 1, 0, "MyImage");
    qmlRegisterType<MyImage1>("MyPlugins", 1, 0, "MyImage1");
    qmlRegisterType<QmlEventFilter>("MyPlugins", 1, 0, "EventFilter");
    qmlRegisterType<Client>("MyPlugins", 1, 0, "Client");
    qmlRegisterType<MyQuickWin>("MyPlugins", 1, 0, "MyQuickWin");
    qmlRegisterType<MyFileIcon>("MyPlugins", 1, 0, "MyFileIcon");
    qmlRegisterType<FileSaveDialog>("MyPlugins", 1, 0, "FileSaveDialog");

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    engine.load(url);

    return app.exec();
}
