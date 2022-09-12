public class TestGuard implements Machinist.IGuard {

    public void call(SObject record) {
        if(record.get('Name') == 'Test') {
            record.addError('No qualification for you!');
        }
    }
}