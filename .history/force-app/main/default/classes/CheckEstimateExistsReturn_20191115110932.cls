public class CheckEstimateExistsReturn {

	public Object Message;
	public Integer MessageCode;
	public List<String> Parameters;
	public String ReturnValue;

	
	public static CheckEstimateExistsReturn parse(String json) {
		return (CheckEstimateExistsReturn) System.JSON.deserialize(json, CheckEstimateExistsReturn.class);
	}
}