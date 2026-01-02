## **ClassWebResource**

Used to access resources located in class path and under /web.

It doesn't work alone. Rather, it is a helper for servlet, such as ZK's update servlet.

it

## DspExtendlet implement Extendlet

The DSP resource processor ({@link Extendlet}) used to parse DSP files loaded from the classpath.

## Extendlet

A plugin of {@link ClassWebResource} to process particular content.

To add a resource processor to {@link ClassWebResource}, use {@link ClassWebResource#addExtendlet}.

https://www.zkoss.org/wiki/ZK_Configuration_Reference/zk.xml/The_Library_Properties/org.zkoss.web.util.resource.dir

https://www.zkoss.org/wiki/ZK_Configuration_Reference/web.xml/ZK_Resource_Engine


NOTE: ExecutionImpl.getPageDefinition use UiFactory a change for resolve url for resource inside bundle
