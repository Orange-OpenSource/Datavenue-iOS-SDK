# Overview

## API keys

The library needs two keys in order to be allowed to make requests to the Datavenue servers :

 - a `CliendID` key which is givent to you from the Orange Partner website.
 - a `master` key which you can access from the Datavenue account page.

## Asynchronous requests

All resources access are asynchronous and require a completion handler to be provided to track the completion of the request.

## Completion handlers

All completion handlers are called from a background queue. Your code is responsible of making sure you code will run on the main thread if the UI must be updated.

Example :

    let client = DVClient(clientID:"sdqfsdf" key:"DMLKDF")
    client.datasourcesWithParams(nil) { (datasources, error) in
        dispatch_async(dispatch_get_main_queue()) {
            // Make UI calls here
	    }
    }

## Request parameters

All requests that return a list of resources (like prototypes, templates, datasources, keys, streams and values) take an optional  `NSDictionary *` of `NSString *`.
Here is the list of the supported options :

 - `pagesize`: the number of returned elements (default: 10)
 - `pagenumber`: the number of the page (default: 0)
 - `search`: filter elements to match a query (more in next section).

Example:

    client.datasourcesWithParams(["pagenumber": 0, "pagesize":100]) { (datasources, error) in
    }

## Search query

 The search option allows to filter the elements by matching a value in the elements fields. It supports two operators : equality `=` and inequality `!=`. The fields are `name`, `description`,`metadata`.  By default the matched text is a substring of the value, but `%` operator can be used to indicate line matching :
 
 - `%ABC` : Matche all values starting with "ABC", like "ABCDEF".
 - `ABC%`: Matches all values ending with "ABC", like "DEADABC".
 - `%ABC%`: Matched all values containing exactly "ABC".

Example:

    // Return all datasources with names that do not start with "temp"
    client.datasourcesWithParams(["search": "name!=%temp"]) { (datasources, error) in
        // handle results
    }
