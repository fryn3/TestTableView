#include "testmodel.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
//    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

//    QGuiApplication app(argc, argv);

//    QQmlApplicationEngine engine;
//    QString qmlRepPath {QML_REPOSITORY_PATH};
//    engine.addImportPath(qmlRepPath);
//    const QUrl url(QStringLiteral("qrc:/main.qml"));
//    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
//                     &app, [url](QObject *obj, const QUrl &objUrl) {
//        if (!obj && url == objUrl)
//            QCoreApplication::exit(-1);
//    }, Qt::QueuedConnection);
//    engine.load(url);

//    return app.exec();
    qputenv("QSG_RENDER_LOOP", "windows");
    qputenv("QSG_INFO", "1");
    qputenv("QT_LOGGING_RULES", "qt.scenegraph.general=true");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

//    SomeBigTableModel model2(2048, 500000);
//    VectorModel model(2048, 500000);
    TestModel model(100, 10);

//    VectorModel model(8*128*1024*1024, 2048);
//    model.setSubtableOrientation(Qt::Vertical);
//    model.setSubtableSizeMax(1024 * 512);
//    SomeBigTableModel model(2049, 128*1024*1024);s

//    SomeBigTableModel model(1024*128 * 129, 2048);

//    SomeBigTableModel model(1050000, 2048);
    QQmlApplicationEngine engine;

    QString qmlRepPath {QML_REPOSITORY_PATH};
    engine.addImportPath(qmlRepPath);

    engine.rootContext()->setContextProperty("cppTableModel", &model);
//    engine.rootContext()->setContextProperty("TableModel2", &model2);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.addImportPath(":/qml");
    engine.load(url);

    return app.exec();
}
