#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSaveFile>
#include <QFileDialog>
#include <QStandardPaths>
#include <QSysInfo>
#include <QTimer>
#include <QDir>
#include <QImage>
#include <cstdio>
#include <QKeyEvent>
#include <QQuickItem>
#include <QFontDatabase>
#include <QRegularExpression>

class Host : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList disks READ disks NOTIFY disksChanged)
    Q_PROPERTY(QString platform READ platform CONSTANT)
public:
    explicit Host(QObject *parent=nullptr) : QObject(parent) {
        connect(&probe, &QProcess::finished, this, [this](int code, QProcess::ExitStatus) {
            if (code == 0) {
                const auto doc = QJsonDocument::fromJson(probe.readAllStandardOutput());
                for (const auto &v : doc.object().value("blockdevices").toArray()) {
                    const auto d = v.toObject();
                    if (d.value("type").toString() != "disk" || d.value("ro").toBool()) continue;
                    const double gib = d.value("size").toDouble() / (1024.*1024.*1024.);
                    if (gib < 1.) continue;
                    const auto path = "/dev/" + d.value("name").toString();
                    drives.append(QVariantMap{{"path",path}, {"size",gib},
                        {"label",QString("%1  /  %2 GiB  /  %3").arg(path).arg(gib,0,'f',1).arg(d.value("model").toString().trimmed())}});
                }
            }
            emit disksChanged();
        });
        probe.start("lsblk", {"--json","--bytes","--output","NAME,SIZE,MODEL,TYPE,RO"});
        QTimer::singleShot(4000, &probe, [this] { if (probe.state()!=QProcess::NotRunning) probe.kill(); });
    }
    QVariantList disks() const { return drives; }
    QString platform() const { return QSysInfo::currentCpuArchitecture() + " / " + (QFile::exists("/sys/firmware/efi") ? "UEFI" : "Legacy firmware"); }
    Q_INVOKABLE bool savePlan(const QVariantMap &input) {
        // Allowlist deliberately excludes passwords and arbitrary execution settings.
        QJsonObject out{{"schemaVersion",1},{"mode","preview"}};
        for (const QString &key : {"language","timezone","keyboard","disk","filesystem","username","hostname","axon","radioport"})
            out.insert(key,QJsonValue::fromVariant(input.value(key)));
        const auto path=QFileDialog::getSaveFileName(nullptr,"Save installation plan",
            QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)+"/neuros-plan.json","JSON (*.json)");
        if(path.isEmpty()) return false;
        QSaveFile file(path);
        if(!file.open(QIODevice::WriteOnly)) return false;
        const auto data=QJsonDocument(out).toJson();
        if(file.write(data)!=data.size()) return false;
        return file.commit();
    }
    Q_INVOKABLE bool validName(const QString &s) const {
        return QRegularExpression("^[a-z_][a-z0-9_-]{0,30}$").match(s).hasMatch();
    }
    Q_INVOKABLE bool validHostname(const QString &s) const {
        return QRegularExpression("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$").match(s).hasMatch();
    }
signals:
    void disksChanged();
private:
    QVariantList drives;
    QProcess probe;
};

int main(int argc,char **argv) {
    QApplication app(argc,argv);
    app.setApplicationName("NeurOS Installer");
    app.setOrganizationName("NeurOS");
    QQuickStyle::setStyle("Basic");
    Host host;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("host",&host);
    QString source=QStringLiteral(NEUROS_SOURCE_DIR "/src/app/Main.qml");
    const auto installed=QCoreApplication::applicationDirPath()+"/../share/neuros-installer/app/Main.qml";
    if(QFile::exists(installed)) source=installed;
    engine.load(QUrl::fromLocalFile(source));
    if(engine.rootObjects().isEmpty()) return 1;
    auto *window=qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    const auto args=app.arguments();
    if(args.contains("--compact")) window->resize(1060,720);
    if(args.contains("--check-ui")) {
        auto key = [window](int code, Qt::KeyboardModifiers mods=Qt::NoModifier) {
            QKeyEvent press(QEvent::KeyPress,code,mods), release(QEvent::KeyRelease,code,mods);
            QCoreApplication::sendEvent(window,&press);
            QCoreApplication::sendEvent(window,&release);
        };
        auto check = [](bool ok,const char *name) { if(!ok) qFatal("FAIL: %s",name); std::printf("PASS: %s\n",name); std::fflush(stdout); };
        QTimer::singleShot(700,window,[window,key,check] {
            check(QFontDatabase::families().contains("DejaVu Sans"),"DejaVu Sans installed");
            check(QFontDatabase::families().contains("DejaVu Sans Mono"),"DejaVu Sans Mono installed");
            key(Qt::Key_Right,Qt::AltModifier);
            check(window->property("page").toInt()==1,"Alt+Right advances");
        });
        QTimer::singleShot(1100,window,[window,key,check] {
            auto *picker=window->findChild<QQuickItem *>("System language");
            check(picker!=nullptr,"language picker available");
            picker->forceActiveFocus(); key(Qt::Key_Space);
        });
        QTimer::singleShot(1500,window,[window,key,check] {
            key(Qt::Key_Down); key(Qt::Key_Return);
            check(window->property("language").toString()==QString::fromUtf8("Türkçe"),"dropdown keyboard selection");
            auto *before=window->activeFocusItem(); key(Qt::Key_Tab);
            check(window->activeFocusItem()!=nullptr && window->activeFocusItem()!=before,"Tab moves focus");
            key(Qt::Key_Right,Qt::AltModifier);
            check(window->property("page").toInt()==2,"next page via keyboard");
            key(Qt::Key_Left,Qt::AltModifier);
            check(window->property("page").toInt()==1,"Alt+Left returns");
            check(window->property("language").toString()==QString::fromUtf8("Türkçe"),"selection survives navigation");
        });
        QTimer::singleShot(1900,window,[window,key,check] {
            window->setProperty("page",3); window->setProperty("diskIndex",-1);
            key(Qt::Key_Right,Qt::AltModifier);
            check(window->property("page").toInt()==3,"missing drive blocks progression");
            window->setProperty("page",4);
            key(Qt::Key_Right,Qt::AltModifier);
            check(window->property("page").toInt()==4,"empty identity blocks progression");
            std::puts("UI keyboard and font checks complete"); std::fflush(stdout);
            QCoreApplication::quit();
        });
    }
    const int idx=args.indexOf("--screenshots");
    if(idx>=0 && idx+1<args.size()) {
        const QString dest=args.at(idx+1);
        QDir().mkpath(dest);
        // Exercise the navigation gate before capturing all six pages.
        QTimer::singleShot(700,window,[window] {
            window->setProperty("page",4);
            if(window->property("canContinue").toBool()) qFatal("Empty account passed validation");
            window->setProperty("username","neuro"); window->setProperty("hostname","neuros");
            window->setProperty("password","test-only-password"); window->setProperty("confirmation","test-only-password");
            if(!window->property("canContinue").toBool()) qFatal("Valid account failed validation");
            window->setProperty("confirmation","mismatch");
            if(window->property("canContinue").toBool()) qFatal("Mismatched passwords passed validation");
            window->setProperty("password",""); window->setProperty("confirmation","");
            window->setProperty("username",""); window->setProperty("hostname","neuros");
            window->setProperty("page",0);
        });
        for(int i=0;i<6;i++) {
            QTimer::singleShot(1100+i*500,window,[window,i]{window->setProperty("page",i);});
            QTimer::singleShot(1400+i*500,window,[window,dest,i]{
                if(!window->grabWindow().save(dest+QString("/step-%1.png").arg(i))) qFatal("Screenshot failed");
            });
        }
        QTimer::singleShot(4400,&app,&QApplication::quit);
    }
    return app.exec();
}
#include "main.moc"
