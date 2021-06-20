#ifndef QMLTEXTFILE_H
#define QMLTEXTFILE_H

#include <QFile>
#include <QFileDevice>
#include <QTextStream>

class QmlTextFile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path MEMBER m_path READ path WRITE set_path NOTIFY pathChanged)
    Q_PROPERTY(int error MEMBER m_error READ error NOTIFY errorChanged)

Q_SIGNALS:
    void pathChanged(QString newpath);
    void errorChanged(int errnum);

public:
    QmlTextFile(QObject *parent = nullptr);
    ~QmlTextFile();

    Q_INVOKABLE void set_path(QString fpath);
    Q_INVOKABLE QString read();
    Q_INVOKABLE int write(QString text);
    Q_INVOKABLE QString error_msg(int errnum);

    Q_INVOKABLE QString path() {return m_path;}
    Q_INVOKABLE int error() {return m_error;}

private:
    Q_DISABLE_COPY(QmlTextFile)
    QString m_path;
    int m_error;

    bool check_error(QFile *file, QTextStream *stream = nullptr);
};

#endif // QMLTEXTFILE_H
