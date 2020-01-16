public without sharing class CreateSytelineEstimate {

	public String Message;
	public Integer MessageCode;
	public List<String> Parameters;
	public String ReturnValue;

	
	public static CreateSytelineEstimate parse(String json) {
		System.debug('PARSE CreateSytelineEstimate ' + json);
		return (CreateSytelineEstimate) System.JSON.deserialize(json, CreateSytelineEstimate.class);
	}
}