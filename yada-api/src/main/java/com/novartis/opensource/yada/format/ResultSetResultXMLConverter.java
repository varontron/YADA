/**
 * 
 */
package com.novartis.opensource.yada.format;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

import javax.sql.rowset.RowSetMetaDataImpl;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentFragment;
import org.w3c.dom.Element;
import org.w3c.dom.Text;

import com.novartis.opensource.yada.adaptor.JDBCAdaptor;

/**
 * The methods in this class use a {@link java.sql.ResultSet} as source data and return it's content as
 * an {@link org.w3c.dom.DocumentFragment} containing {@code ROW} elements with nested data.
 * 
 * @since 0.4.0.0
 * @author David Varon
 *
 */
public class ResultSetResultXMLConverter extends AbstractConverter {

	/**
	 * Constant equal to: {@value}
	 */
	private static final String ROW = "ROW";
	/**
	 * Component of Java XML API
	 */
	private DocumentBuilderFactory docFactory;
	/**
	 * Component of Java XML API
	 */
	private DocumentBuilder        docBuilder;
	/**
	 * Component of Java XML API used to generate the {@link DocumentFragment} to be returned by {@link #convert(Object)}
	 * @see #toString()
	 */
	private Document               doc;
	
	
	/**
	 * Default construcor, instantiates instance vars.
	 * @throws YADAConverterException when the xml api prerequisites can't be instantiated, i.e., when the xml parser can't be configured
	 */
	public ResultSetResultXMLConverter() throws YADAConverterException
	{
		try 
		{
			this.docFactory = DocumentBuilderFactory.newInstance();
			this.docBuilder = this.docFactory.newDocumentBuilder();
			this.doc        = this.docBuilder.newDocument();
		} 
		catch (ParserConfigurationException e) 
		{
			throw new YADAConverterException("XML Document creation failed.");
		}
		
	}
	
	/**
	 * Wraps data in {@code result} in an xml {@link DocumentFragment}
	 * @see com.novartis.opensource.yada.format.AbstractConverter#convert(java.lang.Object)
	 */
	@Override
	public Object convert(Object result) throws YADAConverterException {
		DocumentFragment rows = null;
		
		try 
		{
       rows = getXMLRows((ResultSet)result);
		} 
		catch (SQLException e)
		{
			String msg = "Unable to iterate over ResultSet";
			throw new YADAConverterException(msg,e);
		} 
		catch (JSONException e)
		{
			String msg = "Unable to read Harmony Map";
			throw new YADAConverterException(msg,e);
		}
		return rows;
	}
	
	/**
	 * Constructs an xml fragment of {@code ROW} elements with the result set data
	 * @param rs the result set containing the data to be converted
	 * @return a {@link DocumentFragment} containing the result data wrapped in XML
	 * @throws SQLException when {@code rs} cannot be iterated or accessed
	 */
	private DocumentFragment getXMLRows(ResultSet rs) throws SQLException 
	{
		DocumentFragment rows = this.doc.createDocumentFragment();
		
		ResultSetMetaData rsmd     = rs.getMetaData();
		if (rsmd == null)
			rsmd = new RowSetMetaDataImpl();
		while (rs.next())
		{
			Element row = this.doc.createElement(ROW);
			String colValue;
			for (int i=1; i<=rsmd.getColumnCount(); i++)
			{
				String colName = rsmd.getColumnName(i);
				if(!colName.toLowerCase().equals(JDBCAdaptor.ROWNUM_ALIAS))
				{
					String col = isHarmonized() ? ((JSONObject)this.harmonyMap).getString(colName) : colName;
					if (null == rs.getString(col) || NULL.equals(rs.getString(col)))
					{
						colValue = NULL_REPLACEMENT;
					}
					else
					{
						colValue = rs.getString(col);
					}
					Element column = this.doc.createElement(col);
					Text    value  = this.doc.createTextNode(colValue);
					column.appendChild(value);
					row.appendChild(column);
				}
			}
			rows.appendChild(row);
		}
		return rows;
		
	}
	
	
}