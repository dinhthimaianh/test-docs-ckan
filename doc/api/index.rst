.. _action api:

=========
Hướng dẫn API 
=========

Hướng dẫn API dành cho nhà phát triển muốn viết mã tương tác với các trang web và dữ liệu của họ.

Ví dụ sử dụng API, ứng dụng của bạn có thể:

* Lấy danh sách định dạng JSON của bộ dữ liệu, nhóm hoặc các đối tượng khác của trang web:


  http://203.162.141.37:18080/api/3/action/package_list


  http://203.162.141.37:18080/api/3/action/group_list


  http://203.162.141.37:18080/api/3/action/tag_list


* Lấy một JSON đầy đủ của một bộ dữ liệu, tài nguyên hoặc đối tượng khác:


  http://203.162.141.37:18080/api/3/action/tag_show?id=giao-duc


  http://203.162.141.37:18080/api/3/action/package_show?id=dataset_2020_36676


  http://203.162.141.37:18080/api/3/action/group_show?id=giao-thong


* Tìm kiếm các gói hoặc tài nguyên phù hợp với một truy vấn:


  http://203.162.141.37:18080/api/3/action/package_search?q=spending


  http://203.162.141.37:18080/api/3/action/resource_search?query=name:District%20Names


* Tạo, cập nhật và xóa bộ dữ liệu, tài nguyên và các đối tượng khác

* Lấy một luồng hoạt động của các bộ dữ liệu thay đổi gần đây trên một trang web:


  http://203.162.141.37:18080/api/3/action/recently_changed_packages_activity_list


--------------
Hỗ trợ JSONP 
--------------

Để phục vụ cho các tập lệnh từ các trang web khác muốn truy cập API, dữ liệu có thể 
được trả về ở định dạng JSONP, trong đó dữ liệu JSON được 'padded' bằng một lệnh gọi hàm. 
Hàm được đặt tên trong tham số 'callback'.
Ví dụ một yêu cầu:

``GET /api/rest/dataset/pollution_stats?callback=name-of-callback-function``

.. note :: Chỉ hoạt động cho các yêu cầu GET

----------------------
Chức năng GET-able API 
----------------------

Các hàm được định nghĩa trong `ckan.logic.action.get` cũng có thể được gọi với yêu 
cầu HTTP GET. Ví dụ: để lấy danh sách các bộ dữ liệu từ web, hãy 
mở URL này trong trình duyệt của bạn:

http://203.162.141.37:18080/api/3/action/group_list

Hoặc, để tìm kiếm bộ dữ liệu khớp với truy vấn tìm kiếm ``test`` trên web, 
hãy mở URL này trong trình duyệt của bạn:

http://203.162.141.37:18080/api/3/action/package_search?q=test


Truy vấn tìm kiếm được đưa ra dưới dạng tham số URL ``?q=test``. Nhiều tham số URL có thể được gắn vào, 
phân tách bằng ký tự ``&``, ví dụ để chỉ nhận 5 bộ dữ liệu phù hợp đầu tiên được mở URL này:

http://203.162.141.37:18080/api/3/action/package_search?q=spending&rows=5


.. _api-examples:

------------
Các ví dụ API
------------


Tags 
==========================

Danh sách tất cả các thẻ (tags):

* trình duyệt: http://203.162.141.37:18080/api/3/action/tag_list
* curl: ``curl http://203.162.141.37:18080/api/3/action/tag_list``
* ckanapi: ``ckanapi -r http://203.162.141.37:18080 action tag_list``

Top 10 thẻ (tags) được sử dụng bởi các bộ dữ liệu:

* trình duyệt: http://203.162.141.37:18080/api/action/package_search?facet.field=[%22tags%22]&facet.limit=10&rows=0
* curl: ``curl 'http://203.162.141.37:18080/api/action/package_search?facet.field=\["tags"\]&facet.limit=10&rows=0'``
* ckanapi: ``ckanapi -rhttp://203.162.141.37:18080 action package_search facet.field='["tags"]' facet.limit=10 rows=0``

Tất cả các bộ dữ liệu có thẻ (tag) 'giáo dục':

* trình duyệt: http://203.162.141.37:18080/api/3/action/package_search?fq=tags:giao-duc
* curl: ``curl 'http://203.162.141.37:18080/api/3/action/package_search?fq=tags:giao-duc'``
* ckanapi: ``ckanapi -r http://203.162.141.37:18080 action package_search fq='tags:giao-duc'``
