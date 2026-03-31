/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 6.9.3
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenu>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QTextEdit>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QAction *actionExit;
    QAction *actionAbout;
    QWidget *centralwidget;
    QVBoxLayout *verticalLayout;
    QGroupBox *groupConnection;
    QGridLayout *gridLayout;
    QLabel *labelHost;
    QLineEdit *lineEditHost;
    QLabel *labelPort;
    QLineEdit *lineEditPort;
    QPushButton *btnConnect;
    QLabel *labelStatus;
    QGroupBox *groupRefAudio;
    QHBoxLayout *horizontalLayout_2;
    QLineEdit *lineEditRefAudio;
    QPushButton *btnBrowseRefAudio;
    QGroupBox *groupInput;
    QVBoxLayout *verticalLayout_2;
    QTextEdit *textEditInput;
    QHBoxLayout *horizontalLayout;
    QSpacerItem *horizontalSpacer;
    QPushButton *btnSynthesize;
    QMenuBar *menubar;
    QMenu *menuFile;
    QMenu *menuHelp;
    QStatusBar *statusbar;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName("MainWindow");
        MainWindow->resize(600, 500);
        actionExit = new QAction(MainWindow);
        actionExit->setObjectName("actionExit");
        actionAbout = new QAction(MainWindow);
        actionAbout->setObjectName("actionAbout");
        centralwidget = new QWidget(MainWindow);
        centralwidget->setObjectName("centralwidget");
        verticalLayout = new QVBoxLayout(centralwidget);
        verticalLayout->setObjectName("verticalLayout");
        groupConnection = new QGroupBox(centralwidget);
        groupConnection->setObjectName("groupConnection");
        gridLayout = new QGridLayout(groupConnection);
        gridLayout->setObjectName("gridLayout");
        labelHost = new QLabel(groupConnection);
        labelHost->setObjectName("labelHost");

        gridLayout->addWidget(labelHost, 0, 0, 1, 1);

        lineEditHost = new QLineEdit(groupConnection);
        lineEditHost->setObjectName("lineEditHost");

        gridLayout->addWidget(lineEditHost, 0, 1, 1, 1);

        labelPort = new QLabel(groupConnection);
        labelPort->setObjectName("labelPort");

        gridLayout->addWidget(labelPort, 0, 2, 1, 1);

        lineEditPort = new QLineEdit(groupConnection);
        lineEditPort->setObjectName("lineEditPort");

        gridLayout->addWidget(lineEditPort, 0, 3, 1, 1);

        btnConnect = new QPushButton(groupConnection);
        btnConnect->setObjectName("btnConnect");

        gridLayout->addWidget(btnConnect, 0, 4, 1, 1);

        labelStatus = new QLabel(groupConnection);
        labelStatus->setObjectName("labelStatus");
        labelStatus->setAlignment(Qt::AlignCenter);

        gridLayout->addWidget(labelStatus, 1, 0, 1, 5);


        verticalLayout->addWidget(groupConnection);

        groupRefAudio = new QGroupBox(centralwidget);
        groupRefAudio->setObjectName("groupRefAudio");
        horizontalLayout_2 = new QHBoxLayout(groupRefAudio);
        horizontalLayout_2->setObjectName("horizontalLayout_2");
        lineEditRefAudio = new QLineEdit(groupRefAudio);
        lineEditRefAudio->setObjectName("lineEditRefAudio");

        horizontalLayout_2->addWidget(lineEditRefAudio);

        btnBrowseRefAudio = new QPushButton(groupRefAudio);
        btnBrowseRefAudio->setObjectName("btnBrowseRefAudio");

        horizontalLayout_2->addWidget(btnBrowseRefAudio);


        verticalLayout->addWidget(groupRefAudio);

        groupInput = new QGroupBox(centralwidget);
        groupInput->setObjectName("groupInput");
        verticalLayout_2 = new QVBoxLayout(groupInput);
        verticalLayout_2->setObjectName("verticalLayout_2");
        textEditInput = new QTextEdit(groupInput);
        textEditInput->setObjectName("textEditInput");

        verticalLayout_2->addWidget(textEditInput);

        horizontalLayout = new QHBoxLayout();
        horizontalLayout->setObjectName("horizontalLayout");
        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Policy::Expanding, QSizePolicy::Policy::Minimum);

        horizontalLayout->addItem(horizontalSpacer);

        btnSynthesize = new QPushButton(groupInput);
        btnSynthesize->setObjectName("btnSynthesize");
        btnSynthesize->setEnabled(false);

        horizontalLayout->addWidget(btnSynthesize);


        verticalLayout_2->addLayout(horizontalLayout);


        verticalLayout->addWidget(groupInput);

        MainWindow->setCentralWidget(centralwidget);
        menubar = new QMenuBar(MainWindow);
        menubar->setObjectName("menubar");
        menubar->setGeometry(QRect(0, 0, 600, 24));
        menuFile = new QMenu(menubar);
        menuFile->setObjectName("menuFile");
        menuHelp = new QMenu(menubar);
        menuHelp->setObjectName("menuHelp");
        MainWindow->setMenuBar(menubar);
        statusbar = new QStatusBar(MainWindow);
        statusbar->setObjectName("statusbar");
        MainWindow->setStatusBar(statusbar);

        menubar->addAction(menuFile->menuAction());
        menubar->addAction(menuHelp->menuAction());
        menuFile->addAction(actionExit);
        menuHelp->addAction(actionAbout);

        retranslateUi(MainWindow);

        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QCoreApplication::translate("MainWindow", "TTS Client - Qwen3-TTS", nullptr));
        actionExit->setText(QCoreApplication::translate("MainWindow", "Exit", nullptr));
        actionAbout->setText(QCoreApplication::translate("MainWindow", "About", nullptr));
        groupConnection->setTitle(QCoreApplication::translate("MainWindow", "Connection", nullptr));
        labelHost->setText(QCoreApplication::translate("MainWindow", "Host:", nullptr));
        lineEditHost->setText(QCoreApplication::translate("MainWindow", "localhost", nullptr));
        labelPort->setText(QCoreApplication::translate("MainWindow", "Port:", nullptr));
        lineEditPort->setText(QCoreApplication::translate("MainWindow", "8766", nullptr));
        btnConnect->setText(QCoreApplication::translate("MainWindow", "Connect", nullptr));
        labelStatus->setText(QCoreApplication::translate("MainWindow", "Disconnected", nullptr));
        groupRefAudio->setTitle(QCoreApplication::translate("MainWindow", "Reference Audio (for voice cloning)", nullptr));
        lineEditRefAudio->setPlaceholderText(QCoreApplication::translate("MainWindow", "Path to reference audio file...", nullptr));
        btnBrowseRefAudio->setText(QCoreApplication::translate("MainWindow", "Browse...", nullptr));
        groupInput->setTitle(QCoreApplication::translate("MainWindow", "Text Input", nullptr));
        textEditInput->setPlaceholderText(QCoreApplication::translate("MainWindow", "Enter text to synthesize...", nullptr));
        btnSynthesize->setText(QCoreApplication::translate("MainWindow", "Synthesize", nullptr));
        menuFile->setTitle(QCoreApplication::translate("MainWindow", "File", nullptr));
        menuHelp->setTitle(QCoreApplication::translate("MainWindow", "Help", nullptr));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
