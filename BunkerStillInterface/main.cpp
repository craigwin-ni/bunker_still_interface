
#include "qmlmqttclient.h"
#include "qmltextfile.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
//#include <QtWebView/QtWebView>
#include <QQmlContext>

#include <QDir>
#include <QStandardPaths>
#include <QSysInfo>

int check_dirs();

int main(int argc, char *argv[])
{
    qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
//    QtWebView::initialize();
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<QmlMqttClient>("MqttClient", 1, 0, "MqttClient");
    qmlRegisterUncreatableType<QmlMqttSubscription>("MqttClient", 1, 0, "MqttSubscription", QLatin1String("Subscriptions are read-only"));

    qmlRegisterType<QmlTextFile>("TextFile", 1, 0, "TextFile");

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.addImportPath(":/imports");

    engine.rootContext()->setContextProperty(QStringLiteral("writable_dir_count"), check_dirs());
    QString writablePath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    engine.rootContext()->setContextProperty(QStringLiteral("writable_path"), writablePath);
    engine.rootContext()->setContextProperty(QStringLiteral("operating_system"), QSysInfo::productType());

    engine.load(url);

    return app.exec();
}

int check_dirs()
{
    QString writablePath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    QDir writableDir(writablePath);
    qDebug() << "Writable directory:" << writablePath;

    if (!writableDir.exists()) {
        qDebug() << "Path " << writablePath << "does not exist; will try to create.";
        if (!writableDir.mkpath(".")) {
            qDebug() << "Writable Path " << writablePath << "could not be created.";
            return 0;
        }
    }

    int retval = 1;

    if (!writableDir.exists("pages")) writableDir.mkpath("pages");
    if (writableDir.exists("pages")) ++retval;
    else qDebug() << "'pages' directory could not be created.";

    if (!writableDir.exists("page_units")) writableDir.mkpath("page_units");
    if (writableDir.exists("page_units")) ++retval;
    else qDebug() << "'page_units' directory could not be created.";

    if (!writableDir.exists("annotations")) writableDir.mkpath("annotations");
    if (writableDir.exists("annotations")) ++retval;
    else qDebug() << "'annotations' directory could not be created.";

    return retval;
}
