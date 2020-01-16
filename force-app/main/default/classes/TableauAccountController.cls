public class TableauAccountController {
    // Holds a reference to the account associated with the page controller
    private final Account acct;
       
        
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public TableauAccountController(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        init();
    }

    //Initializes the controller.
    public TableauAccountController() {
        this.acct = null;
        init();
    }

    // Load the tableau username into a static at page load since this won't change
    private void init() {
    }



    // Gets the signed identity; always want to generate this in a getter since the constructor
    // only gets called on original page load and timestamp will skew
    public String getSignedIdentity() {
        String signedIdentity = TableauSparklerUtilities.generateSignedIdentity();
        return signedIdentity;
    }
}