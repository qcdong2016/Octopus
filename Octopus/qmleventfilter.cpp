#include "qmleventfilter.h"
#include "imagemanager.h"

bool QmlEventFilter::eventFilter(QObject *obj, QEvent *event)
{
    if (event->type() == QEvent::KeyPress) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);

        if (_filterPasteEnabled && keyEvent->matches(QKeySequence::Paste)) {
            QClipboard* clipboard = QGuiApplication::clipboard();
            const QMimeData *mimeData = clipboard->mimeData();

            if (mimeData->hasUrls()) {
                emit filesPaste(mimeData->urls());
                return true;
            }
            if (mimeData->hasImage()) {
                QImage image = qvariant_cast<QImage>(mimeData->imageData());
                auto info = ImageManager::instace()->addImage(image);
                emit imagePaste(info->filePath);
                return true;
            }
        }

        if ( _filterEnterEnabled && (keyEvent->key() == Qt::Key_Return || keyEvent->key() == Qt::Key_Enter ))  {
            if (!(keyEvent->modifiers() & Qt::ShiftModifier)) {
                emit enterPressed();
                return true;
            }
        }
    }

    if (_filterDblClickEnabled && event->type() == QEvent::MouseButtonDblClick) {
        QMouseEvent* mev = (QMouseEvent*)event;
        emit dblClicked();
        return true;
    }

    return false;
}
