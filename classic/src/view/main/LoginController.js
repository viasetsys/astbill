Ext.define('MBilling.view.main.LoginController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.login',
    titleWarning: t('Warning'),
    msgFieldsRequired: t('Fill in the fields correctly.'),
    msgAuthenticating: t('Authenticating...'),
    msgEnteringInSystem: t('Entering in system...'),
    msgWelcome: t('Welcome'),
    titleErrorInAuthentication: t('Authentication error'),
    onLogin: function(btn) {
        var me = this,
            loginWin = me.getView(),
            fieldUser = me.lookupReference('user'),
            fieldPassword = me.lookupReference('password'),
            user = fieldUser.getValue();
        if (!fieldUser.isValid() || !fieldPassword.isValid()) {
            Ext.ux.Alert.alert(me.titleWarning, me.msgFieldsRequired, 'warning');
            return false;
        }
        loginWin.setLoading(me.msgAuthenticating);
        Ext.Ajax.request({
            url: 'index.php/authentication/login',
            params: {
                user: user,
                password: fieldPassword.getValue(),
                key: window.captcha
            },
            success: function(response) {
                response = Ext.decode(response.responseText);
                if (response.success) {
                    loginWin.setLoading(me.msgEnteringInSystem);
                    App.init();
                    loginWin.setLoading(false);
                    loginWin.close();
                    Ext.ux.Alert.alert(me.msgWelcome, response.msg, 'information');
                    App.user.logged = response.success;
                } else {
                    if (response.ip) {
                        response.msg = t(response.msg) + "<br>" + t('IP') + ': ' + response.ip;
                    }
                    Ext.ux.Alert.alert(me.titleErrorInAuthentication, t(response.msg), 'error');
                    fieldUser.focus(true);
                    loginWin.setLoading(false);
                }
            }
        });
    },
    onShowLogin: function() {
        this.lookupReference('user').focus(false, 10);
    },
    onSignup: function() {
        window.location = window.location.pathname + '#signup';
        window.location.reload();
    },
    onCreateAccount: function(btn) {
        var me = this,
            loginWin = me.getView();
        formPanel = me.lookupReference('signupForm').getForm();
        values = formPanel.getFieldValues();
        if (values.accept_terms == 0) {
            Ext.ux.Alert.alert(me.titleWarning, t('You need accept the terms to signup'), 'warning');
            return;
        }
        if (!formPanel.isValid()) {
            console.log(values);
            Ext.ux.Alert.alert(me.titleWarning, me.msgFieldsRequired, 'warning');
            return false;
        }
        btn.disable();
        Ext.Ajax.request({
            url: 'index.php/signup/add',
            params: values,
            scope: me,
            success: function(response) {
                response = Ext.decode(response.responseText);
                if (response.success) {
                    Ext.ux.Alert.alert(t('Success'), t(response.msg) + ". <br>" + t('Your username is') + ' ' + response.username, 'success', true, false);
                } else {
                    errors = Helper.Util.convertErrorsJsonToString(response.errors);
                    if (!Ext.isObject(response.errors)) {
                        Ext.ux.Alert.alert(me.titleError, t(errors), 'error', true, 7);
                    } else {
                        Ext.ux.Alert.alert(me.titleWarning, t(errors), 'error', true, 7);
                    }
                    formPanel.markInvalid(response.errors);
                    btn.enable();
                }
            },
            failure: function(response) {
                response = Ext.decode(response.responseText);
                console.log(response);
            }
        });
    }
});