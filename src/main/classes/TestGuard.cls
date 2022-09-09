public class TestGuard implements Machinist.IGuard {

    public void call(SObject record) {
        if(record.get('StageName') == 'Prospecting') {
            record.addError('No qualification for you!');
        }
    }
}