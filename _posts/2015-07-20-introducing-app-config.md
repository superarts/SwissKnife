---
layout: post
title:  "Introducting App Config"
date:   2015-07-20 14:10:00
categories: LSwift LFConfigModel
---

To define:

{% highlight swift %}
	class ICConfigURL: LFConfigModel {
		var root = "http://na.com"
		var promotion = "http://nb.com"
	}
	class ICConfigAPI: LFConfigModel {
		var list = "v1/list"
		var detail = "v1/detail"
	}

	struct IC {
		struct config {
			static let is_publisher = false
			static var url = ICConfigURL(publish:is_publisher)
			static var api = ICConfigAPI(publish:is_publisher)
		}
	}
{% endhighlight %}

To use:

{% highlight swift %}
	struct config {
		static let is_publisher = false
		static var url = ICConfigURL(publish:is_publisher)
		static var api = ICConfigAPI(publish:is_publisher)
	}
{% endhighlight %}

(To be continued)

[lswift]:      http://superarts.github.io/LSwift/
[superarts]:   http://www.superarts.org/blog
