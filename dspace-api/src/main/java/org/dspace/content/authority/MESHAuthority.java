/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.authority;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.message.BasicNameValuePair;
import org.apache.log4j.Logger;
import org.dspace.content.Collection;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Implementation to retrieve object from viaf.org "autosuggest" webservice
 * 
 * @see https://viaf.org/
 *
 * @author Riccardo Fazio (riccardo.fazio at 4science dot it)
 *
 */
public class MESHAuthority implements ChoiceAuthority {

	Logger log = Logger.getLogger(MESHAuthority.class);
	String meshurl = "https://id.nlm.nih.gov/mesh/lookup/descriptor";
	
	@Override
	public Choices getMatches(String field, String text, Collection collection, int start, int limit, String locale) {
	
		List<BasicNameValuePair> args = new ArrayList<BasicNameValuePair>();
		args.add(new BasicNameValuePair("label", text));
        String sUrl = meshurl + "?" + URLEncodedUtils.format(args, "UTF8") + "&match=contains&limit=50";
        try {
			URL url = new URL(sUrl);
        	InputStream is = url.openStream();
        	StringBuffer sb = new StringBuffer();
        	BufferedReader in = new BufferedReader(
            new InputStreamReader(url.openStream()));

            String inputLine;
            while ((inputLine = in.readLine()) != null){
                sb.append(inputLine);
            }
            in.close();
            
            //VIAF responds a json with duplicate keys? must remove them as they are unused
            String str= sb.toString().replaceAll("\"bav\":\"adv\\d+\",", "").replaceAll("\"dnb\":\"\\d+\",", "");
            //JSONObject ob = new JSONObject(str);
            JSONArray results = new JSONArray(str);
            
            Choice[] choices = new Choice[results.length()];
            for(int i=0;i< results.length();i++){
            	JSONObject result = results.getJSONObject(i);
            	String term = result.getString("label");
            	String label = result.getString("label");
            	String authority = result.getString("resource");
            	
            	choices[i] = new Choice(authority, term, label);
            }
            
            return new Choices(choices, 0, choices.length, Choices.CF_ACCEPTED, false);
		} catch (MalformedURLException e) {
			log.error(e.getMessage(),e);
		} catch (IOException e) {
			log.error(e.getMessage(),e);
		} 
        
		return null;
	}

	@Override
	public Choices getBestMatch(String field, String text, Collection collection, String locale) {

		return getMatches(field, text, collection, 0, 1, locale);
	}

	@Override
	public String getLabel(String field, String key, String locale) {

		return key;
	}

}
