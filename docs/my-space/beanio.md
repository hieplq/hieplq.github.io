mapping file on sample has this one

```xml
<beanio xmlns="http://www.beanio.org/2012/03" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.beanio.org/2012/03 http://www.beanio.org/2012/03/mapping.xsd">

```

some issue with that

1. not found http://www.beanio.org/2012/03 http://www.beanio.org/2012/03/mapping.xsd
2. when change to https get certificate error and after that not found also
3. when change to correct link https://raw.githubusercontent.com/beanio/beanio/refs/heads/main/src/org/beanio/xsd/2012/03/mapping.xsd
   get error "access is not allowed due to restriction set by the accessExternalSchema property"
   that error still happend with setting `-Djavax.xml.accessExternalSchema=all`

   reason:

   The XmlMappingReader.createDocumentBuilderFactory method creates a DocumentBuilderFactory. In my environment, it loads the default implementation from JDK 17: com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderImpl. After that, it sets the XMLConstants.ACCESS_EXTERNAL_SCHEMA attribute to an empty value. When the com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl creates the com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderImpl, it passes this attribute to the DocumentBuilderImpl.

   The XMLSecurityPropertyManager is created in the constructor of DocumentBuilderImpl. The javax.xml.accessExternalSchema=all system property is correctly read in the constructor of XMLSecurityPropertyManager. However, later in the constructor of DocumentBuilderImpl, the setDocumentBuilderFactoryAttributes method is called. This method resets the value of javax.xml.accessExternalSchema to the value of the attribute (which, in this case, is empty).

   Additionally, in the constructor of DocumentBuilderImpl, the XMLSecurityPropertyManager is assigned to the DOMParser by calling domParser.setProperty(XML_SECURITY_PROPERTY_MANAGER, fSecurityPropertyMgr);. This also sets properties for fConfiguration (XMLParserConfiguration)

   When StreamFactory.load is called, it invokes com.sun.org.apache.xerces.internal.impl.xs.XMLSchemaLoader.reset(). This method sets fAccessExternalSchema to the value obtained from spm.getValue(XMLSecurityPropertyManager.Property.ACCESS_EXTERNAL_SCHEMA), which is empty.

   Finally, when XMLSchemaLoader.loadSchema() is called, it checks access using SecuritySupport.checkAccess(desc.getExpandedSystemId(), fAccessExternalSchema, JdkConstants.ACCESS_EXTERNAL_ALL). This results in the error:
   "schema_reference: Failed to read schema document 'mapping.xsd', because '[any protocol]' access is not allowed due to restriction set by the accessExternalSchema property."

   Since the XSD is already loaded internally at `"org.beanio.xsd/2012/03/mapping.xsd"`, we might consider removing the `xsi:schemaLocation` attribute from the mapping file in the `StreamFactory.load` method before loading it
