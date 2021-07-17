#include "qmltextfile.h"
#include <string>
using namespace std;

//
//  QmlTextFile methods
//
QmlTextFile::QmlTextFile(QObject *parent) : QObject(parent)
{
}

QmlTextFile::~QmlTextFile()
{
}

void QmlTextFile::set_path(QString fpath)
{
    m_path = fpath;
    emit pathChanged(m_path);
}

QString QmlTextFile::read()
{
    QFile file(m_path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        if (check_error(&file)) return QString();
    }

    QTextStream stream(&file);
    QString text = stream.readAll();
    if (check_error(&file)) return QString();

    file.close();
    return text;
}

int QmlTextFile::write(QString text)
{
    QFile file(m_path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        if (check_error(&file)) return 1;

    QTextStream stream(&file);
    stream << text;
    return check_error(&file, &stream);
}

bool QmlTextFile::remove() {
    QFile file(m_path);
    return file.remove();
}

bool QmlTextFile::check_error(QFile *file, QTextStream *stream) {

    if (file->error()) {
        m_error = file->error();
    } else if (stream && stream->status()) {
        m_error = -stream->status();
    } else {
        m_error = 0;
    }

    if (m_error) {
        emit errorChanged(m_error);
        return 1;
    }

    return 0;
}

QString QmlTextFile::error_msg(int errnum)
{
    QString msg;
    char msg_buffer[150];

    switch(errnum) {
    case (0): return "";
    case (-1): msg = "The text stream has read past the end of the data in the underlying device."; break;
    case (-2): msg = "The text stream has read corrupt data."; break;
    case (-3): msg = "The text stream cannot write to the underlying device."; break;
    case (1): msg = "An error occurred when reading from the file."; break;
    case (2): msg = "An error occurred when writing to the file."; break;
    case (3): msg = "A fatal error occurred."; break;
    case (4): msg = "Out of resources (e.g., too many open files, out of memory, etc.)"; break;
    case (5): msg = "The file could not be opened."; break;
    case (6): msg = "The operation was aborted."; break;
    case (7): msg = "A timeout occurred."; break;
    case (8): msg = "An unspecified error occurred."; break;
    case (9): msg = "The file could not be removed."; break;
    case (10): msg = "The file could not be renamed."; break;
    case (11): msg = "The position in the file could not be changed."; break;
    case (12): msg = "The file could not be resized."; break;
    case (13): msg = "The file could not be accessed."; break;
    case (14): msg = "The file could not be copied."; break;
    default:
        sprintf(msg_buffer, "Unknown error number: %d", errnum);
        msg = msg_buffer;
        break;
    }

    return QString("File error on '") + m_path + QString("': ") + msg;
}

