public class CheckEstimateExistsReturn {

	public String Message;
	public Integer MessageCode;
	public List<String> Parameters;
	public String ReturnValue;

	
	public static CheckEstimateExistsReturn parse(String json) {
		System.debug('PARSE Check Estimate Exists ' + json);
		return (CheckEstimateExistsReturn) System.JSON.deserialize(json, CheckEstimateExistsReturn.class);
	}
}