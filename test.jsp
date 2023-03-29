<%@page import="com.jiuqi.bi.runtime.bsp.common.Color"%>
<%@page import="com.jiuqi.bi.bsp.login.LoginAction"%>
<%@page import="com.jiuqi.bi.bsp.login.ReqReplayDefender"%>
<%@page import="com.jiuqi.bi.runtime.bsp.common.property.IntegerProperty"%>
<%@page import="com.jiuqi.bi.runtime.bsp.common.property.ImgProperty"%>
<%@page import="com.jiuqi.bi.bsp.login.DESUtil"%>
<%@page import="com.jiuqi.bi.runtime.bsp.common.Font"%>
<%@page import="com.jiuqi.bi.runtime.bsp.common.property.FontProperty"%>
<%@page import="com.jiuqi.bi.runtime.bsp.common.property.Property"%>
<%@page import="com.jiuqi.bi.util.Html"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.jiuqi.bi.bsp.portal.PortletRenderContext"%>
<%@page import="com.jiuqi.bi.bsp.portlet.SimpleLoginPortlet"%>
<%
    PortletRenderContext renderContext = new PortletRenderContext(request);
    String winId = Html.encodeText(Html.cleanJsFuncName(renderContext.getWinId()));
    String userName = Html.encodeText(request.getParameter("username"));
    Property logoProperty = renderContext.getProperty(SimpleLoginPortlet.LOGO_IMG_ID);
    Property logoHeightProp = renderContext.getProperty(SimpleLoginPortlet.LOGO_IMG_HEIGHT);
    Property logoWidthProp = renderContext.getProperty(SimpleLoginPortlet.LOGO_IMG_WIDTH);
    IntegerProperty logoHeight = logoHeightProp != null ? (IntegerProperty)logoHeightProp : null;
   	IntegerProperty logoWidth = logoWidthProp != null ? (IntegerProperty)logoWidthProp : null;
    ImgProperty logoImg = logoProperty != null ? (ImgProperty)logoProperty : null;
    String logoImgGuid = logoImg!= null ? logoImg.getValue() : "";
    // logo高度
    int height = (logoHeight!= null && logoHeight.getValue()!= null)  ? logoHeight.getValue() : 0;
 	// logo宽度
    int width = (logoWidth!= null && logoHeight.getValue()!= null) ? logoWidth.getValue() : 0;


    Property inputBgColorProp = renderContext.getProperty(SimpleLoginPortlet.INPUT_BG_ID);

    Color inputBgColor = null;
    if(inputBgColorProp != null){
    	inputBgColor = (Color)inputBgColorProp.getValue();
    }
    String inputBgColorValue = inputBgColor == null ? "transparent" : inputBgColor.getValue();

    String vsign = ReqReplayDefender.createVSign(session, LoginAction.VSIGN_ID_REQ_LOGIN);
%>

<script type="text/javascript" src="<%=request.getContextPath()%>/jslibs/crypto/tripledes.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/jslibs/crypto/mode-ecb-min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/bsp/findPsw/js/aes.js" ></script>
<script type="text/javascript">

    /*    简洁菜单说明：
    *     宽度依照LOGO图宽度
    *	  输入框宽度为LOGO宽度*0.618取整  限制范围为170~250
    *	  输入框之间间距为输入框高度*0.5  最小值15
    *     用户名距Logo图的距离也按输入框间距计算
    *	  按钮下面的空白区高度为Logo图高度*0.5 最小值为输入框高度
    */
    var <%=winId%>_inputWidth = 250;
    //请求签名
    var <%=winId%>_sign = "<%=vsign%>";
    //LOGO图片GUID
    var <%=winId%>_logoImgGuid = '<%=Html.encodeJsText(logoImgGuid)%>';
    // logo高度
    var logoHeight = <%=height%>;
    // logo宽度
    var logoWidth = <%=width%>;

	function <%=winId%>_init(){
		// 窗口id
		var winId = "<%=winId%>";
		// 初始化界面
		<%=winId%>_initUI(winId);
		// 添加事件
	}
	// 初始化界面
	function <%=winId%>_initUI(winId){
		<%=winId%>_initContainer(winId);
	}
	// 添加事件
	function <%=winId%>_bindEvents(winId){
		$("#"+winId+"_userName").focus();
		<%=winId%>_bindCodeEvent(winId);
		<%=winId%>_bindLoginEvent(winId);
		<%=winId%>_bindResetEvent(winId);
	}
	// 创建容器
	function <%=winId%>_initContainer(winId){

		var logo = $("#"+winId+"_logo");
		// 设置logo图片高度和宽度
		if(logoHeight != 0){
			logo.height(logoHeight);
		}
		if(logoWidth != 0){
			logo.width(logoWidth);
		}

		//是否显示验证码
		var visible = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_CAPCHA_ID%>");
		var borderColor = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.BORDER_COLOR_ID%>");
		var borderOpacity = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.BORDER_OPACITY_ID%>");

		var bgColor = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.BGCOLOR_ID%>");

		var hex2rgba = function(hex,opacity){
			var reg = /^#([0-9a-fA-f]{3}|[0-9a-fA-f]{6})$/;
			var sColor = hex.toLowerCase();
		    if(sColor && reg.test(sColor)){
		        if(sColor.length === 4){
		            var sColorNew = "#";
		            for(var i=1; i<4; i+=1){
		                sColorNew += sColor.slice(i,i+1).concat(sColor.slice(i,i+1));
		            }
		            sColor = sColorNew;
		        }
		        //处理六位的颜色值
		        var sColorChange = [];
		        for(var i=1; i<7; i+=2){
		            sColorChange.push(parseInt("0x"+sColor.slice(i,i+2)));
		        }
		        return "rgba(" + sColorChange.join(",") +","+opacity/100 + ")";
		    }else{
		        return hex;
		    }
		};


		$('#' + '<%=winId%>' + '_container').css({
			'border':'1px solid ' + hex2rgba(borderColor.value,borderOpacity),
			'background-color' : hex2rgba(bgColor.value,borderOpacity),
			'border-radius' :'2px'
		});




		//调整登录框的宽高
		var logo = $("#"+winId+"_logo");
//		var imgWidth = logo.width();
//		var imgHeight = logo.height();

		//是否显示验证码
		var showCode = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_CAPCHA_ID%>");
		//是否显示重置
		var showReset = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_RESET_ID%>");
		//input高度
		var height = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_HEIGHT_ID%>");
		//输入框最低32像素
		height = Math.max(32,height);
		//输入框直接的间距,按钮之间的间距
		var inputMarginTop = Math.max(15,height/2),btnMarginLeft = 20;

		var $container = $('#' + '<%=winId%>' + '_container');
		$container.css({
			'opacity':0,
			'filter':'alpha(opacity=0)'
		});
		/*
		var targetWidth = imgWidth,
		targetHeight = imgHeight + inputMarginTop + height +  inputMarginTop
								+ height + inputMarginTop + height + Math.max(imgHeight/2,height) +  (showCode ? (height + inputMarginTop) : 0);
		$container.css({
			'width' : targetWidth + 'px',
			'height' : targetHeight + 'px',
			'opacity':0
		});*/

		//容器宽高
		var $win = $('#' + '<%=winId%>');
		var winWidth = $win.width(),
			winHeight = $win.height();
		//居中模式
		var location = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.LOCATION_ID%>");

		/*
		if(location.id =="<%=SimpleLoginPortlet.LOCATION_DEFAULT_ID%>"){
			$container.css({
				'left' : (winWidth - targetWidth)/2 + 'px',
				'top' : (winHeight - targetHeight)/2 + 'px'
			})
		}*/

		// Logo图片
		<%=winId%>_initLogo(winId,function(imgWidth,imgHeight){
			var targetWidth = imgWidth,
			targetHeight = imgHeight + inputMarginTop + height +  inputMarginTop
									+ height + inputMarginTop + height + Math.max(imgHeight/2,height) +  (showCode ? (height + inputMarginTop) : 0);

			$('#' + '<%=winId%>' + '_container').css({
				'width' : targetWidth + 'px',
				'height' : targetHeight + 'px',
				'opacity': 1,
				'filter':'alpha(opacity=100)'
			});
			//宽度最小为80+10+80 ，最大为600*0.618
			<%=winId%>_inputWidth = Math.max(170, Math.min(Math.floor(600*0.618),Math.ceil(imgWidth*0.618)));

			<%=winId%>_initUserName(winId);
			<%=winId%>_initPassword(winId);
			<%=winId%>_initCode(winId);
			<%=winId%>_initLoginBt(winId);
			<%=winId%>_initResetBt(winId);

			<%=winId%>_bindEvents(winId);
			<%=winId%>_adjustUI(winId);
		});
	}

	//加载LOGO
	function <%=winId%>_initLogo(winId,callback){
		$.bi.log('开始加载图片');
		var logo = $("#"+winId+"_logo");
		$.bi.log("#"+winId+"_logo");
		// Logo图片
		var backgroundImgGuid = "<%= Html.cleanName(logoImgGuid)%>";
		if(backgroundImgGuid){
			$.bi.log('开始backgroundImgGuid：' + backgroundImgGuid);
			var backgroundImgSrc = $.bi.render.tool.getResSrc(backgroundImgGuid);
			logo.off('load').on('load',function(){
				var imgWidth = logo.width();
				var imgHeight = logo.height();
				$.bi.log('load：' + imgWidth + ',' + imgHeight);
				//校验图片大小
				if(window.localStorage && window.localStorage[backgroundImgGuid]){
					var storeData = window.localStorage[backgroundImgGuid];
					$.bi.log('load storeData：' + storeData);
					var xy = storeData.split(',');
					//如果不大于300，有可能是一个错误的logo大小缓存数据，重新读取
					if(imgWidth < (parseInt(xy[0])-10) || imgHeight <(parseInt(xy[1])-10)){
						$.bi.log('size error：' + imgWidth + ',' + imgHeight);
						imgWidth = parseInt(xy[0]);
						imgHeight = parseInt(xy[1]);
						logo.width(imgWidth);
						logo.height(imgHeight);
						$.bi.log('size modify：' + imgWidth + ',' + imgHeight);
					}
				}
				//缓存图片大小
				try{
					if(window.localStorage){
						window.localStorage[backgroundImgGuid] = [imgWidth,imgHeight].join(',');
						$.bi.log('save storeData：' + window.localStorage[backgroundImgGuid]);
					}
				}catch(ex){
				}
				//回调调整大小
				if($.isFunction(callback)){
					callback(imgWidth,imgHeight);
				}
			}).off('error').on('error',function(){
				//TODO 加载失败，但ID没变，为同一图片，可使用缓存大小设置
				if(window.localStorage && window.localStorage[backgroundImgGuid]){
					var storeData = window.localStorage[backgroundImgGuid];
					var xy = storeData.split(',');
					//如果不大于300，有可能是一个错误的logo大小缓存数据，重新读取
					if(xy[0] > 100){
						imgWidth = parseInt(xy[0]);
						imgHeight = parseInt(xy[1]);
						$.bi.log('error：' + imgWidth + ',' + imgHeight);

						//回调调整大小
						if($.isFunction(callback)){
							callback(imgWidth,imgHeight);
						}
					}
				}
			});
			logo.attr("src",backgroundImgSrc);
		}else{
			//TODO
		}
	}

	// 初始化用户名
	function <%=winId%>_initUserName(winId){
		var width = <%=winId%>_inputWidth;
		var logo = $("#"+winId+"_logo");
		var imgWidth = logo.width();
		var height = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_HEIGHT_ID%>");
		//输入框最低32像素
		height = Math.max(32,height);
		//输入框直接的间距,按钮之间的间距
		var inputMarginTop = Math.max(15,height/2),btnMarginLeft = 20;

		var left = (imgWidth-width)/2;
		var top = logo.height() + inputMarginTop;
		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_FONT_ID%>");

		var borderColorProp = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_BORDER_ID%>");
		var borderColor = borderColorProp ? borderColorProp.value : '#FFFFFF';

		var content = "用户名";
		var img = "";
		var canEdit = true;
		//标题显示输入框内部
		var showIn = true;
		//图片显示在输入框内部
		var showImgIn = true;

		//默认 图标和标题显示在左侧。

		if(!content) content = "";
		// 保持与gwt一致
		content = content.replace(/ /g,"&nbsp;&nbsp;");

		var userNameContainer = $("#"+winId+"_userNameContainer");
		var userNameWidget = $("#"+winId+"_userName");
		var userNameTitleWidget = $("#"+winId+"_userNameTitle");
		var userNameImgWidget = $("#"+winId+"_userNameImg");
		var userNameTitleParent = userNameTitleWidget.parent();

		userNameContainer.css("padding","0px");
		userNameContainer.css("left",left);
		userNameContainer.css("top",top);

		userNameWidget.css("font-size",font.size*4/3 + "px");

		userNameWidget.css("height",height - 2);
		userNameWidget.css("width",width);

		userNameContainer.css("line-height",userNameContainer.height()+"px");
		userNameWidget.css("line-height",userNameContainer.height()+"px");
		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		var titleHtml = $.bi.render.tool.getFontHTML(_font,content);
		userNameTitleWidget.html(titleHtml);

		var titleParentWidth = userNameTitleWidget.width() + parseInt(userNameTitleWidget.css("margin-right"));
		if( content && !showIn &&  titleParentWidth  < 50){
			titleParentWidth = 50;
		}

		// 渲染标题图片
		var titleImgSrc = '<%=request.getContextPath()%>' + "/app/portlet/login/I-username.png";

		titleParentWidth += (showIn && showImgIn)?  30 : 20;
		userNameTitleParent.css({
			'background-image' : 'url(' + titleImgSrc + ')',
			'background-repeat' : 'no-repeat',
			'background-position' : 'left center'
		});

		if( content && !showIn  &&  titleParentWidth  < ((showIn && showImgIn)?  80 : 6)){
			titleParentWidth = ((showIn && showImgIn)?  80 : 66);
		}

		// 宽度处理与旧的保持一致
		userNameTitleParent.css("width",titleParentWidth);
		userNameTitleParent.css("height",userNameWidget.outerHeight());

		//图标和文字显示在输入框内
		userNameWidget.css({
			'position':'absolute',
			'left' :'30px',
			'background-color':'transparent',
			'border':'none',
			'width' : (width - 30),
			'outline':'none'
		});
		userNameTitleParent.css({
			"background-color":'white',
			'background-position' : '5px 50%',
			'width' : width + 'px',
			'border-radius' : '1px',
			'border' : '1px solid ' + borderColor
		});
		userNameTitleWidget.css({
			'margin-left':'30px',
			'float' : 'left'
		});

		userNameWidget.on('change',function(){
			if(this.value){
				userNameTitleWidget.html('');
			}
		});

		userNameWidget.on('focus',function(){
			userNameTitleWidget.html('');
		});

		userNameWidget.on('blur',function(){
			if(this.value){
				userNameTitleWidget.html('');
			}else{
				userNameTitleWidget.html(titleHtml);
			}
		});


		if(canEdit==false){
			userNameWidget[0].disabled = true;
		}
		// 为用户名输入框设置默认值
		var userName = "<%=Html.encodeJsText(userName)%>";
		if( userName ){
			userNameWidget.val(userName);
		}else if(showIn && content){
		}

		userNameWidget.css({
			'background':'transparent'
		});
	}

	function <%=winId%>_resetUserName(winId){
		var content = "用户名";

		if(!content) content = "";
		// 保持与gwt一致
		content = content.replace(/ /g,"&nbsp;&nbsp;");

		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_FONT_ID%>");

		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		var titleHtml = $.bi.render.tool.getFontHTML(_font,content);

		var userNameTitleWidget = $("#"+winId+"_userNameTitle");
		userNameTitleWidget.html(titleHtml);
	}

	// 初始化密码
	function <%=winId%>_initPassword(winId){
		var width = <%=winId%>_inputWidth;
		var logo = $("#"+winId+"_logo");
		var imgWidth = logo.width();
		var height = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_HEIGHT_ID%>");
		//输入框最低32像素
		height = Math.max(32,height);
		//输入框直接的间距,按钮之间的间距
		var inputMarginTop = Math.max(15,height/2),btnMarginLeft = 20;
		var left = (imgWidth-width)/2;
		var top = logo.height() + inputMarginTop + height + inputMarginTop;
		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_FONT_ID%>");

		var borderColorProp = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_BORDER_ID%>");
		var borderColor = borderColorProp ? borderColorProp.value : '#FFFFFF';

		var content = "密码";

		var showIn = true;
		//图片显示在输入框内部
		var showImgIn = true;

		if(!content) content = "";
		// 保持与gwt一致
		content = content.replace(/ /g,"&nbsp;&nbsp;");

		var img = '';

		var passwordContainer = $("#"+winId+"_passwordContainer");
		var passwordWidget = $("#"+winId+"_password");
		var passwordTitleWidget = $("#"+winId+"_passwordTitle");
		var passwordImgWidget = $("#"+winId+"_passwordImg");
		var passwordTitleParent = passwordTitleWidget.parent();

		passwordContainer.css("padding","0px");
		passwordContainer.css("left",left);
		passwordContainer.css("top",top);

		passwordWidget.css("font-size",font.size*4/3 + "px");

		// 针对IE浏览器，去掉上下各2px的边框
		passwordWidget.css("height",height-2);
		passwordWidget.css("width",width);

		passwordContainer.css("line-height",passwordContainer.height()+"px");
		passwordWidget.css("line-height",passwordContainer.height()+"px");

		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		var titleHtml = $.bi.render.tool.getFontHTML(_font,content);
		passwordTitleWidget.html(titleHtml);


		var titleParentWidth = passwordTitleWidget.width() + parseInt(passwordTitleWidget.css("margin-right"));
		if(content &&!showIn && titleParentWidth < 50){
			titleParentWidth = 50;
		}

		// 渲染标题图片
		var titleImgSrc = '<%=request.getContextPath()%>' + "/app/portlet/login/I-password.png";

		passwordTitleParent.css({
			'background-image' : 'url(' + titleImgSrc + ')',
			'background-repeat' : 'no-repeat',
			'background-position' : 'left center'
		});

		//titleParentWidth += passwordImgWidget.width();
		titleParentWidth += (showIn && showImgIn)?  30 : 20;
		if(content &&!showIn && titleParentWidth < ((showIn && showImgIn)?  80 : 66)){
			titleParentWidth = ((showIn && showImgIn)?  80 : 66);
		}

		// 宽度处理与旧的保持一致
		passwordTitleParent.width(titleParentWidth);
		passwordTitleParent.height(passwordWidget.outerHeight());


		//图标和文字显示在输入框内
		if(showIn && showImgIn){
			//图标和文字显示在输入框内
			passwordWidget.css({
				'position':'absolute',
				'left' :'30px',
				'background-color':'transparent',
				'border':'none',
				'width' : (width - 30),
				'outline':'none'
			});
			passwordTitleParent.css({
				"background-color":'white',
				'background-position' : '5px 50%',
				'width' : width + 'px',
				'border-radius' : '1px',
				'border' : '1px solid ' + borderColor
			});

			passwordTitleWidget.css({
				'margin-left':'30px',
				'float' : 'left'
			});

			passwordWidget.on('focus',function(){
				passwordTitleWidget.html('');
			});

			passwordWidget.on('blur',function(){
				if(this.value){
					passwordTitleWidget.html('');
				}else{
					passwordTitleWidget.html(titleHtml);
				}
			});

			passwordWidget.on('change',function(){
				if(this.value){
					passwordTitleWidget.html('');
				}
			});
		}
		//图标左侧，文字右侧
		else if(showIn && !showImgIn){
			passwordContainer.css({
				//'background-color':'white',
				'width':width + 30
			});

			passwordWidget.css({
				'background-color':'transparent',
				'position' :'absolute',
				'left':'30px',
				'text-indent':'5px',
				'border':'none'
			});
			passwordTitleParent.css({
				'width':width + 30

			});
			passwordTitleWidget.css({
				'width' : width,
				'background-color':'white',
				'margin-right' : '0px',
				'float': 'left',
		   		'margin-left': '30px',
		    	'text-indent': '5px'
			});

			passwordWidget.on('focus',function(){
				passwordTitleWidget.find('font').css('color','white');
			});

			passwordWidget.on('blur',function(){
				if(this.value){
					passwordTitleWidget.find('font').css('color','white');
				}else{
					passwordTitleWidget.html(titleHtml);
				}
			});

			passwordWidget.on('change',function(){
				if(this.value){
					passwordTitleWidget.find('font').css('color','white');
				}
			});
		}

		passwordWidget.css({
			'background':'transparent'
		});
	}


	function <%=winId%>_resetPassword(winId){
		var content = "密码";

		if(!content) content = "";
		// 保持与gwt一致
		content = content.replace(/ /g,"&nbsp;&nbsp;");

		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_FONT_ID%>");

		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		var titleHtml = $.bi.render.tool.getFontHTML(_font,content);

		var passwordTitleWidget = $("#"+winId+"_passwordTitle");
		passwordTitleWidget.html(titleHtml);
	}


	// 初始化验证码
	function <%=winId%>_initCode(winId){
		var width = <%=winId%>_inputWidth;
		var logo = $("#"+winId+"_logo");
		var imgWidth = logo.width();
		var height = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_HEIGHT_ID%>");
		//输入框最低32像素
		height = Math.max(32,height);
		//输入框直接的间距,按钮之间的间距
		var inputMarginTop = Math.max(15,height/2),btnMarginLeft = 20;
		var left = (imgWidth-width)/2;
		var top = logo.height() + inputMarginTop + height + inputMarginTop + height + inputMarginTop;
		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_FONT_ID%>");
		var content = '验证码';
		var img = '';
		var visible = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_CAPCHA_ID%>");

		var borderColorProp = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_BORDER_ID%>");
		var borderColor = borderColorProp ? borderColorProp.value : '#FFFFFF';

		var showIn = true;
		//图片显示在输入框内部
		var showImgIn = true;

		if(!content) content = "";
		// 保持与gwt一致
		content = content.replace(/ /g,"&nbsp;&nbsp;");

		var codeContainer = $("#"+winId+"_codeContainer");
		var codeWidget = $("#"+winId+"_code");
		var codeTitleWidget = $("#"+winId+"_codeTitle");
		var codeTitleImgWidget = $("#"+winId+"_codeTitleImg");
		var codeImgWidget = $("#"+winId+"_codeImg");
		var codeTitleParent = codeTitleWidget.parent();

		codeWidget.css("font-size",font.size);

		var codeImgWidth = 40;
		var codeImgMarginLeft = 3;

		if(!visible){
			codeContainer.css("display","none");
			return;
		}

		codeWidget.width(width);
		codeWidget.height(height-2);

		codeContainer.css("padding","0px");
		codeContainer.css("left",left);
		codeContainer.css("top",top);

		// 针对IE浏览器，去掉上下各2px的边框
		if($.browser.msie) {
			codeWidget.css("height",height - 4);
			codeWidget.css("width",width - codeImgWidth- codeImgMarginLeft - 4);

			// IE下光标垂直居中，chrome、firefox会自动居中
			codeWidget.css("line-height",height - 4 + "px");

			codeContainer.css("height",height);
		}else{
			codeWidget.css("height",height);
			codeWidget.css("width",width - codeImgWidth- codeImgMarginLeft);
		}
		codeContainer.css("line-height",codeContainer.height()+"px");
		codeWidget.css("line-height",codeContainer.height()+"px");

		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		var titleHtml = $.bi.render.tool.getFontHTML(_font,content);
		codeTitleWidget.html(titleHtml);

		// 与旧的保持一致
		var titleParentWidth = codeTitleWidget.width() + parseInt(codeTitleWidget.css("margin-right"));
		if(content && titleParentWidth < 50){
			titleParentWidth = 50;
		}

		// 渲染标题图片
		if(img != null && img !=""){
			var titleImgSrc = $.bi.render.tool.getResSrc(img);

			codeTitleParent.css({
				'background-image' : 'url(' + titleImgSrc + ')',
				'background-repeat' : 'no-repeat',
				'background-position' : 'left center'
			});

			//titleParentWidth += codeTitleImgWidget.width();
			titleParentWidth += (showIn && showImgIn)?  30 : 20;
			if(content &&!showIn && titleParentWidth < ((showIn && showImgIn)?  80 : 66)){
				titleParentWidth = ((showIn && showImgIn)?  80 : 66);
			}
		}

		// 宽度处理与旧的保持一致
		codeTitleParent.width(titleParentWidth);
		//codeTitleParent.height(codeContainer.height());

		// 渲染验证码图片
		codeImgWidget.width(codeImgWidth);
		codeImgWidget.height(18);
		codeImgWidget.css("margin-left",codeImgMarginLeft);
		codeImgWidget.css("cursor","pointer");

		var codeImgWidth = height/18*40 > 18 ? Math.max(80,height/18*40) :18 ;

		//图标和文字显示在输入框内
		if(showIn && showImgIn){
			codeContainer.css({
				'width' : width
			});
			codeWidget.css({
				'position':'absolute',
				'text-indent' : '10px',
				'left' :'0px',
				'background-color':'transparent',
				'border':'none',
				'outline':'none',
				'width' : (width - codeImgWidth -10)
			});


			codeTitleParent.css({
				"background-color":'white',
				'background-position' : '5px 50%',
				'width' : (width - codeImgWidth -10) + 'px',
				'height' : height - 2,
				'border-radius' : '1px',
				'border' : '1px solid ' + borderColor
			});
			codeTitleWidget.css({
				'margin-left':'10px',
				'float' : 'left',
				'display': 'block',
				'height' : (height - 2) + 'px',
				'line-height' : (height - 2) + 'px'
			});


			codeImgWidget.css({
				'width' : codeImgWidth,
				'height' : height - 2,
				'right' : '0px',
				'position':'absolute'
			});
			codeWidget.on('focus',function(){
				codeTitleWidget.html('');
			});

			codeWidget.on('blur',function(){
				if(this.value){
					codeTitleWidget.html('');
				}else{
					codeTitleWidget.html(titleHtml);
				}
			});

			codeWidget.on('change',function(){
				if(this.value){
					codeTitleWidget.html('');
				}
			});
		}
		//图标左侧，文字右侧
		else if(showIn && !showImgIn){
			codeContainer.css({
				//'background-color':'white',
				'width':width + 30
			});

			codeWidget.css({
				'background-color':'transparent',
				'position' :'absolute',
				'left':'30px',
				'text-indent':'5px',
				'width':width - codeImgWidth,
				'border':'none'
			});

			codeImgWidget.css({
				'width' : codeImgWidth,
				'height' : height,
				'position':'absolute',
				'right' : '0px'
			});

			codeTitleParent.css({
				'width':width + 30 - codeImgWidth
			});


			codeTitleWidget.css({
				'width' : width - codeImgWidth - 3,
				'margin-right' : '0px',
				'float': 'left',
		   		'margin-left': '30px',
		    	'text-indent': '5px'
			});

			codeWidget.on('focus',function(){
				codeTitleWidget.find('font').css('color','white');
			});

			codeWidget.on('blur',function(){
				if(this.value){
					codeTitleWidget.find('font').css('color','white');
				}else{
					codeTitleWidget.html(titleHtml);
				}
			});
			codeWidget.on('change',function(){
				if(this.value){
					codeTitleWidget.find('font').css('color','white');
				}
			});
		}

		codeWidget.css({
			'background':'transparent'
		});

		<%=winId%>_refreshCode(codeImgWidget);
	}


	function <%=winId%>_resetCode(winId){
		var content = "用户名";

		if(!content) content = "";
		// 保持与gwt一致
		content = content.replace(/ /g,"&nbsp;&nbsp;");

		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_FONT_ID%>");

		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		var titleHtml = $.bi.render.tool.getFontHTML(_font,content);

		var userNameTitleWidget = $("#"+winId+"_userNameTitle");
		userNameTitleWidget.html(titleHtml);
	}

	// 刷新验证码
	function <%=winId%>_refreshCode(codeImgWidget){
		// 加上时间，保证每次都刷新图片
		var time = new Date().getTime();
		var src = $.bi.render.tool.getContextPath() + "/bsp-loginAction.action?action=getCodeImg&timeamp=" + time;
		codeImgWidget.attr("src",src);
	}
	// 初始化登录按钮
	function <%=winId%>_initLoginBt(winId){
		var showReset = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_RESET_ID%>");
		var width = showReset? <%=winId%>_inputWidth - 90 : <%=winId%>_inputWidth;
		var logo = $("#"+winId+"_logo");
		var imgWidth = logo.width();
		var height = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_HEIGHT_ID%>");
		//输入框最低32像素
		height = Math.max(32,height);
		//输入框直接的间距,按钮之间的间距
		var inputMarginTop = Math.max(15,height/2),btnMarginLeft = 20;
		var left = (imgWidth-<%=winId%>_inputWidth)/2;
		var showCode = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_CAPCHA_ID%>");
		var top = logo.height() + inputMarginTop + height + inputMarginTop + height + inputMarginTop + (showCode ? (height + inputMarginTop) : 0);
		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.BTN_FONT_ID%>");

		var bgImg = '';
		var bgColor = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.LOGIN_BTN_BGCOLOR_ID%>");
		var statusColor = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.LOGIN_BTN_HOVERCOLOR_ID%>");

		var stateImg = '';
		var content = '登录';
		var loginBt = $("#"+winId+"_loginBt");

		// 在chrome、firefox下,采用jquery的width()、height()方法设置的宽度、高度与预期不一致，采用css属性的方式来设置
		loginBt.css("width",width);
		loginBt.css("height",height);
		loginBt.css("left",left);
		loginBt.css("top",top);
		loginBt.css({
			'line-height' : height + 'px',
			'text-align' : 'center',
			'background-color' : bgColor.value
		});

		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		$.bi.render.tool.setFontStyle(loginBt,_font);

		// 背景图片、替换图片
		if(bgImg){
			//<%=winId%>_setButtonBgImg(loginBt,bgImg);
		}
		loginBt.mouseenter(function(e){
			if(stateImg != undefined && stateImg != ""){
				<%=winId%>_setButtonBgImg(loginBt,stateImg);
			}
			loginBt.css({
				'background-color' : statusColor.value
			});
		});
		loginBt.mouseleave(function(e){
			//<%=winId%>_setButtonBgImg(loginBt,bgImg);
			loginBt.css({
				'background-color' : bgColor.value
			});
		});
	}

	// 初始化重置按钮
	function <%=winId%>_initResetBt(winId){
		var visible = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_RESET_ID%>");

		var showCode = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_CAPCHA_ID%>");
		var logo = $("#"+winId+"_logo");
		var imgWidth = logo.width();
		var height = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_HEIGHT_ID%>");
		//输入框最低32像素
		height = Math.max(32,height);
		//输入框直接的间距,按钮之间的间距
		var inputMarginTop = Math.max(15,height/2),btnMarginLeft = 20;

		var left = (imgWidth-<%=winId%>_inputWidth)/2 + 120 + 30;

		var width = 80;
		var top = logo.height() + inputMarginTop + height + inputMarginTop + height + inputMarginTop + (showCode ? (height + inputMarginTop) : 0);
		var font = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.BTN_FONT_ID%>");
		var bgImg = '';
		var stateImg =  '';
		var content = '重置';
		var bgColor = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.RESET_BTN_BGCOLOR_ID%>");
		var statusColor = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.RESET_BTN_HOVERCOLOR_ID%>");



		var resetBt = $("#"+winId+"_resetBt");

		if(!visible){
			resetBt.css("display","none");
			return;
		}

		// 在chrome、firefox下,采用jquery的width()、height()方法设置的宽度、高度与预期不一致，采用css属性的方式来设置
		resetBt.css("width",width);
		resetBt.css("height",height);
		resetBt.css({
			'line-height' : height + 'px',
			'text-align' : 'center'
		});
		resetBt.css("right",(imgWidth-<%=winId%>_inputWidth)/2);
		resetBt.css("top",top);
		//resetBt.val(content);

		var _font = $.extend(true,{},font);
		_font.size = _font.size*4/3;
		$.bi.render.tool.setFontStyle(resetBt,_font);

		resetBt.css({
			'background-color' : bgColor.value
		});

		// 背景图片、替换图片
		//<%=winId%>_setButtonBgImg(resetBt,bgImg);
		//if(stateImg != undefined && stateImg != ""){
			resetBt.mouseenter(function(e){
				//<%=winId%>_setButtonBgImg(resetBt,stateImg);

				resetBt.css({
					'background-color' : statusColor.value
				});
			});
			resetBt.mouseleave(function(e){
				//<%=winId%>_setButtonBgImg(resetBt,bgImg);
				resetBt.css({
					'background-color' : bgColor.value
				});
			});
		//}
	}
	// 为按钮设置背景图片
	function <%=winId%>_setButtonBgImg(bt,img){
		if(img !=undefined){
			var imgSrc = $.bi.render.tool.getResSrc(img);
			var imgUrl = "url(" + "'" + imgSrc + "'" + ")";
			bt.css("border-width","0px");
			bt.css("background-image",imgUrl);
			bt.css("background-repeat","repeat");
			bt.css("cursor","pointer");
		}
	}
	// 调整界面
	function <%=winId%>_adjustUI(winId){
		$.bi.log('_adjustUI');
		// 以下代码是为了保证所有输入框标题都右对齐
		var userNameTitleParent = $("#"+winId+"_userNameTitle").parent();
		var userNameTitleWidth = userNameTitleParent.width();

		var passwordTitleParent = $("#"+winId+"_passwordTitle").parent();
		var passwordTitleWidth = passwordTitleParent.width();

		var codeTitleParent = $("#"+winId+"_codeTitle").parent();
		var codeTitleWidth = codeTitleParent.width();

		// 将标题中最大的宽度，设置到每个标题容器上
		var max = Math.max(userNameTitleWidth,passwordTitleWidth);
		max = Math.max(max,codeTitleWidth);

		//max += 3;

		userNameTitleParent.width(max);
		passwordTitleParent.width(max);

		//调整登录框的宽高
		var logo = $("#"+winId+"_logo");
		var imgWidth = logo.width();
		var imgHeight = logo.height();
		$.bi.log('adjust..' + imgWidth + ',' + imgHeight);
		//是否显示验证码
		var showCode = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_CAPCHA_ID%>");
		//是否显示重置
		var showReset = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.SHOW_RESET_ID%>");
		//input高度
		var height = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.INPUT_HEIGHT_ID%>");
		//输入框最低32像素
		height = Math.max(32,height);
		//输入框直接的间距,按钮之间的间距
		var inputMarginTop = Math.max(15,height/2),btnMarginLeft = 20;

		var targetWidth = imgWidth,
		targetHeight = imgHeight + inputMarginTop + height +  inputMarginTop
								+ height + inputMarginTop + height + Math.max(imgHeight/2,height) +  (showCode ? (height + inputMarginTop) : 0);


		var $container = $('#' + '<%=winId%>' + '_container');
		$container.css({
			'width' : targetWidth + 'px',
			'height' : targetHeight + 'px'
		});

		//容器宽高
		var $win = $('#' + '<%=winId%>');
		var winWidth = $win.width(),
			winHeight = $win.height();
		//居中模式
		var location = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.LOCATION_ID%>");

		if(!location ||  location.id =="<%=SimpleLoginPortlet.LOCATION_DEFAULT_ID%>"){
			$container.css({
				'left' : (winWidth - targetWidth)/2 + 'px',
				'top' : (winHeight - targetHeight)/2 + 'px'
			})
		}else{
			var _left = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.LOCATION_CUSTOM_LEFT_ID%>");
			var _top = $.bi.render.getPortletPropertyValue(winId,"<%=SimpleLoginPortlet.LOCATION_CUSTOM_TOP_ID%>");
			$container.css({
				'left' :Math.max(0,(winWidth - targetWidth)/2 - _left) + 'px',
				'top' : Math.max(0,(winHeight - targetHeight)/2 - _top) + 'px'
			})
		}


		//codeTitleParent.width(max);
	}
	// 绑定验证码事件
	function <%=winId%>_bindCodeEvent(winId){
		var codeContainer = $("#"+winId+"_codeContainer");
		// 验证码可见的话，绑定验证码事件
		if(codeContainer.css("display") != "none"){
			var codeImgWidget = $("#"+winId+"_codeImg");
			codeImgWidget.click(function(){
				// 刷新验证码
				<%=winId%>_refreshCode(codeImgWidget);
			});
		}
	}
	// 绑定登录事件
	function <%=winId%>_bindLoginEvent(winId){
		var loginBt = $("#"+winId+"_loginBt");
		loginBt.click(function(){
			<%=winId%>_login(winId);
		});

		var userNameWidget = $("#"+winId+"_userName");
		userNameWidget.keypress(function(event){
			var keyCode = event.keyCode;
			// 按下enter键
			if (keyCode == 13) {
				<%=winId%>_login(winId);
			}
		});

		var passwordWidget = $("#"+winId+"_password");
		passwordWidget.keypress(function(event){
			var keyCode = event.keyCode;
			// 按下enter键
			if (keyCode == 13) {
				<%=winId%>_login(winId);
			}
		});

		var codeWidget = $("#"+winId+"_code");
		codeWidget.keypress(function(event){
			var keyCode = event.keyCode;
			// 按下enter键
			if (keyCode == 13) {
				<%=winId%>_login(winId);
			}
		});
	}
	// 登录事件
	function <%=winId%>_login(winId){
		var userName = $.trim($("#"+winId+"_userName").val());
		if(userName==""){
			$.bi.ui.alert("用户名不能为空！",function(){
				$("#"+winId+"_userName").focus();
			});
			return;
		}

		var codeContainer = $("#"+winId+"_codeContainer");
		if(codeContainer.css("display")=="none"){
			// 不验证验证码,登录
			<%=winId%>_ajaxLogin(winId);
		}
		else{
			var code = $.trim($("#"+winId+"_code").val());
			if(code == ""){
				$.bi.ui.alert("验证码不能为空！",function(){
					$("#"+winId+"_code").focus();
				});
				return;
			}
			// 验证验证码
			$.ajax({
				url:"bsp-loginAction.action",
				type:"post",
				contentType: "application/x-www-form-urlencoded; charset=utf-8",
				data:{
					"action":"validateCode",
					"code":code
				},
				dataType:"text",
				success:function(data){
					if(data=="true"){
						// 验证通过进行登录
						<%=winId%>_ajaxLogin(winId);
					}else{
						$.bi.ui.alert("验证码输入错误！",function(){
							$("#"+winId+"_code").focus();
						});
						var codeImgWidget = $("#"+winId+"_codeImg");
						<%=winId%>_refreshCode(codeImgWidget)
					}
				},
			 	error:function (XMLHttpRequest,textStatus,errorThrown) {
					$.bi.ui.error("验证验证码出现错误",XMLHttpRequest.responseText,XMLHttpRequest);
					$("#"+winId+"_code").focus();
			 	}
			});
		}
	}


	/**说明：
	 1.如果加密解密涉及到前端和后端，则这里的key要保持和后端的key一致
	 2.AES的算法模式有好几种（ECB,CBC,CFB,OFB），所以也要和后端保持一致
	 3.AES的补码方式有两种（PKS5，PKS7），所以也要和后端保持一致
	 4.AES的密钥长度有三种（128,192,256，默认是128），所以也要和后端保持一致
	 5.AES的加密结果编码方式有两种（base64和十六进制），具体怎么选择由自己定，但是加密和解密的编码方式要统一
	*/
	// 设置密钥
	var key = CryptoJS.enc.Utf8.parse("cBssbHB3ZA==HKXT");
	/**
	 * AES加密(需要先加载aes.js文件)
	 * @param word
	 * @returns {*}
	 */
	function encrypt(password){
	    var srcs = CryptoJS.enc.Utf8.parse(password);
	    var encrypted = CryptoJS.AES.encrypt(srcs, key, {mode:CryptoJS.mode.ECB,padding: CryptoJS.pad.Pkcs7});
	    return encrypted.toString();
	}

	/**
	 * AES解密
	 * @param word
	 * @returns {*}
	 */
	function decrypt(password){
	    var decrypt = CryptoJS.AES.decrypt(password, key, {mode:CryptoJS.mode.ECB,padding: CryptoJS.pad.Pkcs7});
	    return CryptoJS.enc.Utf8.stringify(decrypt).toString();
	}


	// 发送ajax请求，进行登录
	function <%=winId%>_ajaxLogin(winId){

		var userName = $.trim($("#"+winId+"_userName").val());
		// 对用户名进行加密
		userName =  encrypt(userName);
		// 对密码进行加密
		var pw = $("#"+winId+"_password").val();
		pw = encrypt(pw);

		var daysMemMe = false;

		var code = '';
		var codeContainer = $("#"+winId+"_codeContainer");
		if(codeContainer.css("display")!="none"){
			code = $.trim($("#"+winId+"_code").val());
		}

		$.ajax({
			url:"bsp-loginAction.action",
			type:"post",
			contentType: "application/x-www-form-urlencoded; charset=utf-8",
			data:{
				action:"login",
				c: code,
				u:userName,
				p:pw,
				isEncode:true,
				encryptType:"A",
				daysMemMe : daysMemMe,
				v:md5(("u=" + userName + ",p=" + pw + ",daysMemMe=" + daysMemMe + ",vsign=") + <%=winId%>_sign),
				//请求签名
				vsign : <%=winId%>_sign
			},
			dataType:"json",
			success:function(data){
				if(typeof(data)!= "undefined" && data!=null){
					if (true == data.need_change_pwd) {
						window.location.href="./changepwd.jsp";
						return;
					}
					else if (data.isPasswordPrompt == true) {
						$.bi.ui.confirm("密码即将过期，是否立即修改密码?", function() {
							window.location.href="./changepwd.jsp";
							return;
						}, function() {
							if( data.threeRole && data.threeRole == 'safety'){
								window.location.href = $.bi.cleanURLDomXss(window.location.href);

								return;
							}
							else if( data.threeRole && data.threeRole == 'sys'){
								window.location.href = $.bi.cleanURLDomXss(window.location.href);
								return;
							}
							else if( data.threeRole && data.threeRole == 'audit'){
								window.location.href = $.bi.cleanURLDomXss(window.location.href);
								return;
							}
							else if(data.bsp_returnUrl){
								window.location.href = data.bsp_returnUrl;
							}
							else {
								portalAppData.clear();
								portalAppData.init(data);
								portalAppData.render();
								//渲染密码管理
								portalAppData.renderPasswordManager_GWT();

								if($('#noteframe').length){
									$('#noteframe').attr('src','noteframe.jsp');
								}

								if (BI.MC) {
									BI.MC.broadcast({channel:"sys", topic:"login", data:""});
								}
							}
						}, "密码修改提醒", {closable: false});
					}
					else if( data.threeRole && data.threeRole == 'safety'){
						window.location.href = $.bi.cleanURLDomXss(window.location.href);
						return;
					}
					else if( data.threeRole && data.threeRole == 'sys'){
						window.location.href = $.bi.cleanURLDomXss(window.location.href);
						return;
					}
					else if( data.threeRole && data.threeRole == 'audit'){
						window.location.href = $.bi.cleanURLDomXss(window.location.href);
						return;
					}
					else if(data.bsp_returnUrl){
						window.location.href = data.bsp_returnUrl;
					}
					else {
						portalAppData.clear();
						portalAppData.init(data);
						portalAppData.render();
						//渲染密码管理
						portalAppData.renderPasswordManager_GWT();

						if($('#noteframe').length){
							$('#noteframe').attr('src','noteframe.jsp');
						}

						if (BI.MC) {
							BI.MC.broadcast({channel:"sys", topic:"login", data:""});
						}
					}
				}
			},
		 	error:function (XMLHttpRequest,textStatus,errorThrown) {
		 		//登录失败时自动刷新验证码
				if(codeContainer.css("display")!="none") {
					var codeImgWidget = $("#" + winId + "_codeImg");
					<%=winId%>_refreshCode(codeImgWidget);
				}
				$.bi.ui.alert(XMLHttpRequest.responseText,function(){
					$("#"+winId+"_password").focus();
				});
		 	}
		});
	}

	// 重置事件
	function <%=winId%>_bindResetEvent(winId){
		var resetBt =  $("#"+winId+"_resetBt");
		resetBt.click(function(){
			$("#"+winId+"_userName").val("");
			$("#"+winId+"_password").val("");
			$("#"+winId+"_code").val("");

			<%=winId%>_resetUserName(winId);
			<%=winId%>_resetPassword(winId);
			<%=winId%>_resetCode(winId);

			$("#"+winId+"_userName").focus();
		});
	}

	function <%=winId%>_resize(winId){
		$.bi.log('resize');
		<%=winId%>_adjustUI(winId);
	}

	function <%=winId%>_layout(portletEntity,winId){
		$.bi.log('layout');
		<%=winId%>_adjustUI('<%=winId%>');
	}
</script>
<style>
	#<%=winId%>_container input{
	  	padding:0px;
  		margin:0px;
		-moz-box-sizing: border-box;
		-webkit-box-sizing: border-box;
		box-sizing: border-box;
		font-size:14px;
		font-weight:normal;
		font-family:		Microsoft YaHei,Simsun,Arial;
	}


	#<%=winId%>_container .inputContainer{
		background-color: <%=Html.cleanName(inputBgColorValue, '#')%>;
	}
</style>
<div style="position:relative;width:100%;height:100%;overflow:hidden;" id="<%=winId%>_container">
	<img id='<%=winId%>_logo' ></img>
	<div id="<%=winId%>_userNameContainer" style="position:absolute;">
		<div style="float:left;" class='inputContainer'>
			<img id="<%=winId%>_userNameImg" style="display:none;float:left;vertical-align:middle;"></img>
			<span id="<%=winId%>_userNameTitle" style="float:right;"></span>
			<span style="clear:both"></span>
		</div>
		<input id="<%=winId%>_userName" type="text"></input>
		<div style="clear:both;"></div>
	</div>
	<div id="<%=winId%>_passwordContainer" style="position:absolute;">
		<div style="float:left;" class='inputContainer'>
			<img id="<%=winId%>_passwordImg" style="display:none;float:left;vertical-align:middle;"></img>
			<span id="<%=winId%>_passwordTitle" style="float:right;"></span>
			<span style="clear:both"></span>
		</div>
		<input id="<%=winId%>_password" type="password" autocomplete="off"></input>
		<div style="clear:both;"></div>
	</div>
	<div id="<%=winId%>_codeContainer" style="position:absolute;">
		<div style="float:left;" class='inputContainer'>
			<img id="<%=winId%>_codeTitleImg" style="display:none;float:left;vertical-align:middle;"></img>
			<span id="<%=winId%>_codeTitle" style="float:right;"></span>
			<span style="clear:both"></span>
		</div>
		<input id="<%=winId%>_code" type="text"></input>
		<img id="<%=winId%>_codeImg" style="vertical-align:middle;cursor:pointer;" title="看不清,点击刷新"></img>
		<div style="clear:both;"></div>
	</div>
	<div id="<%=winId%>_loginBt" type="button" style="position:absolute;border:none;cursor:pointer;">登录</div>
	<div id="<%=winId%>_resetBt" type="button" style="position:absolute;border:none;cursor:pointer;">重置</div>
</div>
