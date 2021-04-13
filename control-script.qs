var status = {
    widget: null,
    finishedPageVisible: false,
    installationFinished: false,
    loginPageCount: 0
}

function abortInstaller()
{
    installer.setDefaultPageVisible(QInstaller.Introduction, false);
    installer.setDefaultPageVisible(QInstaller.TargetDirectory, false);
    installer.setDefaultPageVisible(QInstaller.ComponentSelection, false);
    installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false);
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
    installer.setDefaultPageVisible(QInstaller.PerformInstallation, false);
    installer.setDefaultPageVisible(QInstaller.LicenseCheck, false);

    var abortText = "<font color='red' size=3>" + qsTr("Installation failed:") + "</font>";

    var error_list = installer.value("component_errors").split(";;;");
    abortText += "<ul>";
    // ignore the first empty one
    for (var i = 0; i < error_list.length; ++i) {
        if (error_list[i] !== "") {
            log(error_list[i]);
            abortText += "<li>" + error_list[i] + "</li>"
        }
    }
    abortText += "</ul>";
    installer.setValue("FinishedText", abortText);
}

function log() {
    var msg = ["QTCI: "].concat([].slice.call(arguments));
    console.log(msg.join(" "));
}

function printObject(object) {
    var lines = [];
    for (var i in object) {
        lines.push([i, object[i]].join(" "));
    }
    log(lines.join(","));
}

function tryFinish()
{
    if (status.finishedPageVisible && status.installationFinished) {
        if (status.widget.RunItCheckBox) {
            status.widget.RunItCheckBox.setChecked(false);
        }
        log("Press Finish Button");
        gui.clickButton(buttons.FinishButton);
    }
}

function Controller()
{
    log("Controller");
    installer.installationFinished.connect(function() {
        status.installationFinished = true;
        gui.clickButton(buttons.NextButton, 3000);
        tryFinish();
    });
    installer.autoRejectMessageBoxes;
    installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
    installer.setMessageBoxAutomaticAnswer("installationError", QMessageBox.OK);
    installer.setMessageBoxAutomaticAnswer("installationErrorWithRetry", QMessageBox.Ignore);
    installer.setMessageBoxAutomaticAnswer("AuthorizationError", QMessageBox.OK);
    installer.setMessageBoxAutomaticAnswer("OperationDoesNotExistError", QMessageBox.Ignore);
    installer.setMessageBoxAutomaticAnswer("isAutoDependOnError", QMessageBox.OK);
    installer.setMessageBoxAutomaticAnswer("isDefaultError", QMessageBox.OK);
    installer.setMessageBoxAutomaticAnswer("ElevationError", QMessageBox.OK);
    installer.setMessageBoxAutomaticAnswer("Error", QMessageBox.OK);
    installer.setMessageBoxAutomaticAnswer("stopProcessesForUpdates", QMessageBox.Ignore);
    installer.setMessageBoxAutomaticAnswer("TargetDirectoryInUses", QMessageBox.No);
    installer.setMessageBoxAutomaticAnswer("AlreadyRunning", QMessageBox.OK);
    
    // Allow to cancel installation for arguments --list-packages
    installer.setMessageBoxAutomaticAnswer("cancelInstallation", QMessageBox.Yes);
}

// Question for tracking usage data, refuse it
Controller.prototype.DynamicTelemetryPluginFormCallback = function()
{
    //logCurrentPage()
    log("Telemetry Plugin Form Page");
    console.log(Object.keys(page().TelemetryPluginForm.statisticGroupBox))
    var radioButtons = page().TelemetryPluginForm.statisticGroupBox
    radioButtons.disableStatisticRadioButton.checked = true
    proceed()
}

Controller.prototype.ObligationsPageCallback = function()
{
    log("Obligations Menu Page");
    var page = gui.pageWidgetByObjectName("ObligationsPage");
    page.obligationsAgreement.setChecked(true);
    page.completeChanged();
    gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.StartMenuDirectoryPageCallback = function()
{
    log("Start Menu Page");
    gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.WelcomePageCallback = function()
{
    log("Welcome Page");
    gui.clickButton(buttons.NextButton, 3000);

    var widget = gui.currentPageWidget();

    widget.completeChanged.connect(function() {
        gui.clickButton(buttons.NextButton, 3000);
    });
}

Controller.prototype.CredentialsPageCallback = function()
{
    log("Credentials Page");
    var login = installer.environmentVariable("QT_INSTALLER_LOGIN_MAIL");
    var password = installer.environmentVariable("QT_INSTALLER_LOGIN_PW");

    if ( login === "" ){
        log("Please provide the qt login username via ENV 'QT_INSTALLER_LOGIN_MAIL'!");
    }else{
        log("qt login:"+login);
    }
    if ( password === "" ){
        log("Please provide the qt login password via ENV 'QT_INSTALLER_LOGIN_PW!");
    }

    //if (login === "" || password === "") {
    //    gui.clickButton(buttons.CommitButton, 3000);
    //}

    var widget = gui.currentPageWidget();
    widget.loginWidget.EmailLineEdit.setText(login);
    widget.loginWidget.PasswordLineEdit.setText(password);

    // Testing the automated instasll on Ubuntu VBox with wine, the login does not work despite correct credentials.
    // Move back with the button once, then the script will go forward afterwards.
    if (status.loginPageCount==0){
        status.loginPageCount=1;
        gui.clickButton(buttons.BackButton, 3000);
    }
    
    gui.clickButton(buttons.CommitButton, 3000);
}

Controller.prototype.ComponentSelectionPageCallback = function()
{
    log("ComponentSelectionPageCallback");

    function list_packages() {
      var components = installer.components();
      log("Available components: " + components.length);
      var packages = [""];
      for (var i = 0 ; i < components.length ;i++) {
          packages.push(components[i].name);
      }
      log(packages.join(" "));
    }

    if ( installer.environmentVariable("QT_LIST_PACKAGES") ) {
        list_packages();
        gui.clickButton(buttons.CancelButton);
        return;
    }

    log("Select components");

    function trim(str) {
        return str.replace(/^ +/,"").replace(/ *$/,"");
    }

    var widget = gui.currentPageWidget();

    var packageList = installer.environmentVariable("QT_INSTALL_PACKAGES");
    var packages = trim(packageList).split(" ");
    if (packages.length > 0 && packages[0] !== "") {
        widget.deselectAll();
        for (var i in packages) {
            var pkg = trim(packages[i]);
            log("Select " + pkg);
            widget.selectComponent(pkg);
        }
    } else {
       log("Use default package list");
    }

    widget.selectAll();
    gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.IntroductionPageCallback = function()
{
    log("Introduction Page");
    log("Retrieving meta information from remote repository");

    /*
     Online installer 3.0.6 
     - Don't click buttons.NextButton directly. It will skip the componenet selection.
    */

    if (installer.isOfflineOnly()) {
        gui.clickButton(buttons.NextButton, 3000);
    }
}

Controller.prototype.TargetDirectoryPageCallback = function()
{
    log("Target Directory Page");
    var version = installer.value("ProductVersion");
    var widget = gui.currentPageWidget();

    if (widget != null) {
        dir = installer.environmentVariable("QT_INSTALL_DIR");
        widget.TargetDirectoryLineEdit.setText(dir);
        log("Set target installation dir: "+widget.TargetDirectoryLineEdit.text);
    }

    gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.LicenseAgreementPageCallback = function()
{
    log("Accept license agreement");
    var widget = gui.currentPageWidget();

    if (widget != null) {
        widget.AcceptLicenseRadioButton.setChecked(true);
    }

    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function()
{
    log("Ready to install");
    gui.clickButton(buttons.CommitButton, 3000);
}

Controller.prototype.PerformInstallationPageCallback = function()
{
    log("PerformInstallationPageCallback");
    gui.clickButton(buttons.CommitButton, 3000);
}

Controller.prototype.FinishedPageCallback = function()
{
    log("FinishedPageCallback");

    var widget = gui.currentPageWidget();

    if (widget.LaunchQtCreatorCheckBoxForm) {
        // No this form for minimal platform
        widget.LaunchQtCreatorCheckBoxForm.launchQtCreatorCheckBox.setChecked(false);
    }

    if (widget.RunItCheckBox) {
        // LaunchQtCreatorCheckBoxForm may not work for newer version.
        widget.RunItCheckBox.setChecked(false);
    }

    // Bug? Qt 5.9.5 and Qt 5.9.6 installer show finished page before the installation completed
    // Don't press "finishButton" immediately

    status.finishedPageVisible = true;
    status.widget = widget;
    tryFinish();
}
