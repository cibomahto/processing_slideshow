// Simple tools to maintain a list of available images, that are stored in XML.
// 
// By Matt Mets, 2012
//
// Usage example:
//
//  String updateURL = "http://dev.canalmercer.com/index.php/moderate/feed";
//  String historyFile = "/Users/matthewmets/Documents/Processing/test_loaddata/data/feed.xml";
//
//  // Restore the last set of images that we knew about
//  Map<Integer, String> currentImages = readImageList(historyFile);
//  println("Current images (" + currentImages.size() + ")");
//  printImageList(currentImages);
//  
//  // Get any new ones
//  Map<Integer, String> newImages = updateImageList(historyFile, updateURL);
//  println("New images (" + newImages.size() + ")");
//  printImageList(newImages);

import java.io.IOException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Attr;
import org.xml.sax.SAXException;

// Print the contents of an image list to the console
void printImageList(Map<Integer, String> imageList) {
  Iterator it = imageList.entrySet().iterator();
  while (it.hasNext()) {
    Map.Entry pairs = (Map.Entry)it.next();
    println(pairs.getKey() + ": " + pairs.getValue());
  }
}


// Get the current images available on the site, subtract the ones we already know, and return the difference.
Map<Integer, String> getNewImages(Map<Integer, String> originalImages, String newURL) {
  
  Map<Integer, String> uniqueImages = new HashMap<Integer, String>();
  Map<Integer, String> newImages =  readImageList(newURL);
  
  Iterator it = newImages.entrySet().iterator();
  while (it.hasNext()) {
    Map.Entry pairs = (Map.Entry)it.next();
    if(originalImages.containsKey(pairs.getKey())) {
//      println("Found Duplicate->" + pairs.getKey());  
    }
    else {
//      println("Found new image->" + pairs.getKey());
      uniqueImages.put((Integer)pairs.getKey(), (String)pairs.getValue());
    }
  }
  
  return uniqueImages;
}


// Update the given image list, and return any new images.
Map<Integer, String> updateImageList(String originalListURL, String updateListURL) {
  // Restore the last set of images that we knew about
  Map<Integer, String> originalList = readImageList(originalListURL);
//  println("Current images (" + currentImages.size() + ")");
//  printImageList(currentImages);
  
  // Get any new ones
  Map<Integer, String> newImages = getNewImages(originalList, updateListURL);
//  println("New images (" + newImages.size() + ")");
//  printImageList(newImages);
  
  // Then add them to the image list
  originalList.putAll(newImages);
  writeImageList(originalList, originalListURL);
  
  return newImages;
}


// Read a map of images from an xml file
// Adapted from:
// http://www.mkyong.com/java/how-to-count-xml-elements-in-java-dom-parser/
Map<Integer, String> readImageList(String listURL) {

  Map<Integer, String> availableImages = new HashMap<Integer, String>();

  try {
    DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
    DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
    Document doc = docBuilder.parse(listURL);

    NodeList list = doc.getElementsByTagName("photo");

    for (int temp = 0; temp < list.getLength(); temp++) {

      Node nNode = list.item(temp);
      if (nNode.getNodeType() == Node.ELEMENT_NODE) {
        Element eElement = (Element) nNode;

        availableImages.put(int(eElement.getAttributeNode("id").getValue()), eElement.getAttributeNode("src").getValue());
      }
    }
  } 
  catch (ParserConfigurationException pce) {
    pce.printStackTrace();
  } 
  catch (IOException ioe) {
    ioe.printStackTrace();
  } 
  catch (SAXException sae) {
    sae.printStackTrace();
  }

  return availableImages;
}


// Save a map of images as an XML file
void writeImageList(Map<Integer, String> imageList, String filename) {
  try {
    DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
    DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
    Document document = documentBuilder.newDocument();

    // Root Element
    Element rootElement = document.createElement("feed");
    document.appendChild(rootElement);

    Iterator it = imageList.entrySet().iterator();
    while (it.hasNext ()) {
      Map.Entry pairs = (Map.Entry)it.next();

      // photo attributes
      Element photo = document.createElement("photo");
      rootElement.appendChild(photo);

      Attr id = document.createAttribute("id");
      id.setValue(pairs.getKey().toString());
      photo.setAttributeNode(id);

      Attr src = document.createAttribute("src");
      src.setValue(pairs.getValue().toString());
      photo.setAttributeNode(src);
    }

    // The XML document we created above is still in memory
    // so we have to output it to a real file.
    // In order to do it we first have to create
    // an instance of DOMSource
    DOMSource source = new DOMSource(document);

    // PrintStream will be responsible for writing
    // the text data to the file
    PrintStream ps = new PrintStream(filename);
    StreamResult result = new StreamResult(ps);

    // Once again we are using a factory of some sort,
    // this time for getting a Transformer instance,
    // which we use to output the XML
    TransformerFactory transformerFactory = TransformerFactory
      .newInstance();
    Transformer transformer = transformerFactory.newTransformer();

    // The actual output to a file goes here
    transformer.transform(source, result);
  } 
  catch (ParserConfigurationException pce) {
    pce.printStackTrace();
  } 
  catch (FileNotFoundException pce) {
    pce.printStackTrace();
  } 
  catch (TransformerConfigurationException pce) {
    pce.printStackTrace();
  } 
  catch (TransformerException pce) {
    pce.printStackTrace();
  }
}
