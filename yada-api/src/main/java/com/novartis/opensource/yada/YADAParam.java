package com.novartis.opensource.yada;

/**
 * @author David Varon
 *
 */
public class YADAParam
{

	/**
	 * Constant with value equal to: {@value}
	 */
	public final static int    OVERRIDEABLE = 0;
	/**
	 * Constant with value equal to: {@value}
	 */
	public final static int    NONOVERRIDEABLE = 1;
	/**
	 * Constant with value equal to: {@value}
	 */
	public final static String QUERY = "Q";
	/**
	 * Constant with value equal to: {@value}
	 */
	public final static String APP   = "A";
	/**
	 * The scope of the parameter, either {@link #QUERY} or {@link #APP}
	 */
	private String  target; //TODO target is going to be an app or query name, so scope needs to be calculated
	/**
	 * The parameter name
	 * @see YADARequest
	 */
	private String  name;
	/**
	 * The parameter value
	 */
	private String  value;
	/**
	 * The parameter mutation rule, either {@link #OVERRIDEABLE} or {@link #NONOVERRIDEABLE}
	 */
	private int     rule; 
	/**
	 * Flag indicating whether the parameter value was derived from the yada index, as a default parameter
	 * or set in the request
	 */
	private boolean isDefault = false;
	/**
	 * Default constructor
	 */
	public YADAParam()
	{
	}
	
	/**
	 * Create new instance with default {@code isDefault} value of {@code false}.
	 * @param target the parameter target, an app or query
	 * @param name the parameter name
	 * @param value the parameter value
	 * @param rule the parameter mutability rule, {@link #OVERRIDEABLE} or {@link #NONOVERRIDEABLE}
	 */
	public YADAParam(String name, String value, String target, int rule)
	{
		setTarget(target);
		setName(name);
		setValue(value);
		setRule(rule);
	}
	
	/**
	 * Create a new instance with, presumably from the YADA index, with {@code isDefault} set to {@code true}.
	 * @param target the parameter target, an app or query
	 * @param name the parameter name
	 * @param value the parameter value
	 * @param rule the parameter mutability rule, {@link #OVERRIDEABLE} or {@link #NONOVERRIDEABLE}	 * @param isDefault
	 * @param isDefault set to {@code true} when the parameter is retrieved from the YADA index, defaults to {@code false}
	 */
	public YADAParam(String name, String value, String target, int rule, boolean isDefault)
	{
		setName(name);
		setValue(value);
		setTarget(target);
		setRule(rule);
		setDefault(isDefault);
	}
	
	/**
	 * Standard accessor for variable.
	 * @return the target, either an app or query.
	 */
	public String getTarget()
	{
		return this.target;
	}
	/**
	 * Standard mutator for variable.
	 * @param target the target to set
	 */
	public void setTarget(String target)
	{
		this.target = target;
	}
	/**
	 * Standard accessor for variable.
	 * @return the name
	 */
	public String getName()
	{
		return this.name;
	}
	/**
	 * Standard mutator for variable.
	 * @param name the name to set
	 */
	public void setName(String name)
	{
		this.name = name;
	}
	/**
	 * Standard accessor for variable.
	 * @return the value
	 */
	public String getValue()
	{
		return this.value;
	}
	/**
	 * Standard mutator for variable.
	 * @param value the value to set
	 */
	public void setValue(String value)
	{
		this.value = value;
	}
	/**
	 * Standard accessor for variable.
	 * @return the rule, either {@link #OVERRIDEABLE} or {@link #NONOVERRIDEABLE}
	 */
	public int getRule()
	{
		return this.rule;
	}
	/**
	 * Standard mutator for variable.
	 * @param rule the rule to set
	 */
	public void setRule(int rule)
	{
		this.rule = rule;
	}
	/**
	 * Standard accessor for variable.
	 * @return the isDefault status, {@code true} if the parameter was retrieved from the YADA index.
	 */
	public boolean isDefault()
	{
		return this.isDefault;
	}
	/**
	 * Standard mutator for variable.
	 * @param isDefault the isDefault to set
	 */
	public void setDefault(boolean isDefault)
	{
		this.isDefault = isDefault;
	}
	
	/**
	 * Returns a json object-like string of the contents of the object.
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString()
	{
		return "{\"name\":\""+getName()
				+"\",\"value\":\""+getValue()
				+"\",\"target\":\""+getTarget()
				+"\",\"rule\":\""+getRule()
				+"\",\"isDefault\":\""+String.valueOf(isDefault())+"\"}";
	}

	
}