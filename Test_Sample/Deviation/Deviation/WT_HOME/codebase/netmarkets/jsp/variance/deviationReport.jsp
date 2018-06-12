<%
	out.println("welcome");
	wt.fc.WTReference ref = null;
	String devNumber = "";
	String reportOid = "";
	wt.util.WTProperties props = wt.util.WTProperties.getLocalProperties();
	String hostURL = props.getProperty("java.rmi.server.hostname");
	String portNum = props.getProperty("wt.webserver.port");
	String oid = request.getParameter("oid");
	out.println("oid is"+oid);
	String instance = com.infoengine.au.NamingService.getIEProperties().getProperty("com.infoengine.taskProcessor");
	wt.httpgw.URLFactory urlFactory = new wt.httpgw.URLFactory();
  	String baseUrl = urlFactory.getBaseHREF();
	out.println("Base url is"+baseUrl);
	try {
			ref = new wt.fc.ReferenceFactory().getReference(oid);
	}catch(Exception e) {

	}
	wt.fc.Persistable persistable =  ref.getObject();
	wt.change2.WTVariance devObj = (wt.change2.WTVariance)persistable;
	devNumber = devObj.getNumber();
	String filename=devNumber+".pdf";
	out.println("Deviation number is"+devNumber);
	wt.query.QuerySpec qs = new wt.query.QuerySpec(wt.query.template.ReportTemplate.class);
	qs.appendWhere(new wt.query.SearchCondition(wt.query.template.ReportTemplate.class,"name",wt.query.SearchCondition.EQUAL,"Deviation"));
	//qs.appendWhere(new wt.query.SearchCondition(wt.query.template.ReportTemplate.class,"name",wt.query.SearchCondition.EQUAL,"DeviationTest"));
	wt.fc.QueryResult resultSet = wt.fc.PersistenceHelper.manager.find(qs);
	while(resultSet.hasMoreElements())

	{
		out.println("There are reports");
		reportOid = Long.toString(((wt.query.template.ReportTemplate)resultSet.nextElement()).getPersistInfo().getObjectIdentifier().getId());
		out.println("report id is"+reportOid);

	}	
		
		response.setContentType("application/pdf");  
		response.setHeader("Content-Disposition", "attachment; filename=" + filename); 
		String redirectURL ="/servlet/WindchillAuthGW/wt.enterprise.URLProcessor/URLTemplateAction?format=formatDelegate&delegateName=DEVREPORTPDF&oid=OR%3Awt.query.template.ReportTemplate%3A" + reportOid + "&action=ExecuteReport&NUMBER=" + devNumber;
		RequestDispatcher rd = getServletContext().getRequestDispatcher(redirectURL);
    	rd.forward(request,response);
		
		%>
