#ifndef QMLEVENTFILTER_H
#define QMLEVENTFILTER_H

#include <QQuickItem>
#include <QKeyEvent>
#include <QGuiApplication>
#include <QClipboard>
#include <QMimeData>
#include <QImage>

class QmlEventFilter : public QQuickItem
{
    Q_OBJECT
public:
    Q_PROPERTY(QObject * source READ getSource WRITE setSource)
    Q_PROPERTY(bool filterEnterEnabled READ getFilterEnterEnabled WRITE setFilterEnterEnabled)
    Q_PROPERTY(bool filterPasteEnabled READ getFilterPasteEnabled WRITE setFilterPasteEnabled)
    Q_PROPERTY(bool filterDblClickEnabled READ getFilterDblClickEnabled WRITE setFilterDblClickEnabled)

public:
    QmlEventFilter()
    {
        _source = nullptr;
        _filterEnterEnabled = false;
        _filterPasteEnabled = false;
    }

    ~QmlEventFilter()
    {
        if (_source != nullptr)
            _source->removeEventFilter(this);
    }

    void setSource(QObject *source)
    {
        source->installEventFilter(this);
        _source = source;
    };

    QObject * getSource() { return _source; }
    void setFilterEnterEnabled(bool value) { _filterEnterEnabled = value; }
    bool getFilterEnterEnabled() { return _filterEnterEnabled; }

    void setFilterPasteEnabled(bool value) { _filterPasteEnabled = value; }
    bool getFilterPasteEnabled() { return _filterPasteEnabled; }

    void setFilterDblClickEnabled(bool value) { _filterDblClickEnabled = value; }
    bool getFilterDblClickEnabled() { return _filterDblClickEnabled; }

signals:
    void enterPressed();
    void imagePaste(const QString& imagePath);
    void filesPaste(const QList<QUrl> files);
    void textPaste(const QString& text);
    void dblClicked();

private:

    void keyPressEvent(QKeyEvent *event) override
    {
        // This is actually called when the QML event handler hasn't accepted the event
        _qmlAccepted = false;

        // Ensure the event won't be propagated further
        event->setAccepted(true);
    }

    void keyReleaseEvent(QKeyEvent *event) override
    {
        // This is actually called when the QML event handler hasn't accepted the event
        _qmlAccepted = false;

        // Ensure the event won't be propagated further
        event->setAccepted(true);
    }

    bool eventFilter(QObject *obj, QEvent *event) override;

private:
    QObject *_source;
    bool _filterEnterEnabled;
    bool _filterPasteEnabled;
    bool _filterDblClickEnabled;
    bool _qmlAccepted;
};

#endif // QMLEVENTFILTER_H
