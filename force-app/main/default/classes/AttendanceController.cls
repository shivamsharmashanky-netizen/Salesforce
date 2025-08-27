public with sharing class AttendanceController {
    @AuraEnabled
    public static Id startDay() {
        Id uid = UserInfo.getUserId();
        DateTime nowDt = System.now();

        Employee_Attendance_c__c today = [
            SELECT Id, Status__c, Login_Time__c, Logout_Time__c
            FROM Employee_Attendance_c__c
            WHERE Login_Time__c >= :Date.today()
              AND Login_Time__c < :Date.today().addDays(1)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        // If not found, catch and create
        if (today == null) {
            today = new Employee_Attendance_c__c(
                Login_Time__c = nowDt,
                Status__c = 'Active'
            );
            insert today;
            return today.Id;
        }

        // If found but inactive, reactivate
        if (today.Status__c != 'Active') {
            today.Login_Time__c = (today.Login_Time__c == null) ? nowDt : today.Login_Time__c;
            today.Logout_Time__c = null;
            today.Status__c = 'Active';
            update today;
        }
        return today.Id;
    }

    @AuraEnabled
    public static Id endDay() {
        Id uid = UserInfo.getUserId();
        Datetime nowDt = System.now();

        Employee_Attendance_c__c today = [
            SELECT Id, Status__c, Login_Time__c
            FROM Employee_Attendance_c__c
            WHERE Login_Time__c >= :Date.today()
              AND Login_Time__c < :Date.today().addDays(1)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (today == null) {
            // Optionally throw error or create a record (business choice)
            today = new Employee_Attendance_c__c(
                Login_Time__c = nowDt,
                Status__c = 'Active'
            );
            insert today;
        }
        today.Logout_Time__c = nowDt;
        today.Status__c = 'Inactive';
        update today;
        return today.Id;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isActiveToday() {
        Id uid = UserInfo.getUserId();
        List<Employee_Attendance_c__c> rows = [
            SELECT Id, Status__c, Login_Time__c
            FROM Employee_Attendance_c__c
            WHERE Login_Time__c >= :Date.today()
              AND Login_Time__c < :Date.today().addDays(1)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        return !rows.isEmpty() && rows[0].Status__c == 'Active';
    }
}