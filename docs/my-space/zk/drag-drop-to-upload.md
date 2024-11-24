## How upload working on zk

**Upload component**: Any zk component, like a button or link, can be added to the user interface. When clicked, it will open a file dialog, allowing the user to select files. Refer to the [guide](https://www.zkoss.org/wiki/ZK_Developer's_Reference/UI_Patterns/File_Upload_and_Download) for specific setup details.

**Note**: Even if we set up a button component to handle file uploads, it doesn't automatically transform into a file input field. It still functions as a standard button, file input is handle by [Upload](https://www.zkoss.org/javadoc/latest/jsdoc/classes/zul.Upload.html) widget

Each upload component you define triggers the creation of a corresponding [Upload](https://www.zkoss.org/javadoc/latest/jsdoc/classes/zul.Upload.html) widget. This widget is responsible for generating the file input field, which serves as control to show file dialog

<details>
  <summary>See **this._inp = inp;** on Upload.prototype.initContent</summary>

```js
Upload.prototype.initContent = function () {
    var wgt = this._wgt,
      parent = this._parent,
      ref = wgt.$n(),
      html = '<span class="z-upload"' + (this._tooltiptext ? ' title="' + zUtl.encodeXML(this._tooltiptext) + '"' : '') // ZK-751
      + '><form enctype="multipart/form-data" method="POST">' + '<input name="file" type="file"'
      // multiple="" for Firefox, multiple for Chrome
      + (this.multiple == 'true' ? ' multiple="" multiple' : '') + (this.accept ? ' accept="' + this.accept.replace(new RegExp('\\|', 'g'), ',') + '"' : '') + ' hidefocus="true" tabindex="-1" style="height:' + ref.offsetHeight + 'px"/></form></span>';
    if (parent) jq(parent).append(DOMPurify.sanitize(html));else jq(wgt).after(DOMPurify.sanitize(html));
    delete this._formDetached;
    //B50-3304877: autodisable and Upload
    if (!wgt._autodisable_self) {
      var self = this;
      //B65-ZK-2111: Sync later to prevent the external style change button offset height/width.
      setTimeout(function () {
        self.sync();
      }, 50);
    }
    var outer = this._outer = parent ? parent.lastChild : ref.nextSibling,
      inp = outer.firstChild.firstChild;
    this._inp = inp;
    if (zk.opera) {
      //in opera, relative not correct (test2/B50-ZK-363.zul)
      outer.style.position = 'absolute';
      _addSyncQue(this);
    }
    inp.z$proxy = ref;
    inp._ctrl = this;
    jq(inp).change(_onchange);
  };

```

</details>

**NOTE**:

* The onChange event of the file input is registered within the Upload.prototype.initContent method. See jq(inp).change(_onchange);
* The file input (and entire form) is being regenerated in somewhere, so avoid caching it
* ref points to the upload component (dom)
* The reference to the file input is obtained using the following code (The condition  parent != null might occur when using [UploadManage](https://www.zkoss.org/javadoc/latest/jsdoc/classes/zul.UploadManager.html) it's EE feature)

  * ```js
    var outer = this._outer = parent ? parent.lastChild : ref.nextSibling,
    inp = outer.firstChild.firstChild;
    ```

When use click to upload component (use Button as example) onclick handle call Upload to show file browse

<details>
  <summary>see **this._uplder.openFileDialog()** on Button.prototype.doClick_</summary>

```js
Button.prototype.doClick_ = function (evt) {
    if (!evt.domEvent)
      // mobile will trigger doClick twice
      return;
    if (!this._disabled) {
      this.fireX(evt);
      if (!this._upload) zul.wgt.ADBS.autodisable(this);else this._uplder.openFileDialog();
      if (!evt.stopped) {
        var href = this._href,
          isMailTo = href ? href.toLowerCase().startsWith('mailto:') : false;
        if (href) {
          // ZK-2506: use iframe to open a 'mailto' href
          if (isMailTo) {
            var ifrm = jq.newFrame('mailtoFrame', href, undefined);
            jq(ifrm).remove();
          } else {
            zUtl.go(href, {
              target: this._target || (evt.data.ctrlKey ? '_blank' : '')
            });
          }
        }
        _super.prototype.doClick_.call(this, evt, true);
      }
    }
    //Unlike DOM, we don't proprogate to parent (otherwise, onClick
    //will fired)
  };
```

</details>

After user choose file onchange is called to handle it and do upload file

<details>
  <summary>_onchange to handle file upload</summary>

```js
function _onchange(_evt) {
  var n = this,
    upload = n._ctrl,
    form = n.form,
    // we don't use jq().remove() in this case, because we have to use its reference.
    p = form.parentNode;
  p.parentNode.removeChild(p);
  upload._formDetached = true;
  var fileName = !n.files || n.files.length == 1 ? n.value : function (files) {
    var fns = [];
    for (var len = files.length; len--;) fns.unshift(files[len].name);
    return fns.join(',');
  }(n.files);
  _start(n._ctrl, form, fileName);
}
if (zk.opera) {
  //opera only
  var _syncQue = [],
    _syncId,
    _syncNow = function () {
      for (var j = _syncQue.length; j--;) _syncQue[j].sync();
    },
    _addSyncQue = function (upld) {
      if (!_syncQue.length) _syncId = setInterval(_syncNow, 1500);
      _syncQue.push(upld);
    },
    _rmSyncQue = function (upld) {
      _syncQue.$remove(upld);
      if (_syncId && !_syncQue.length) {
        clearInterval(_syncId);
        _syncId = undefined;
      }
    };
}
```

</details>

## How to implement drag and drop to upload file

1. Need a normal upload component setup follow [guide](https://www.zkoss.org/wiki/ZK_Developer's_Reference/UI_Patterns/File_Upload_and_Download)
2. Setup a drop area, this one reference to upload component
3. when handle drop event

   1. get reference to file input
   2. set [FileList](https://developer.mozilla.org/en-US/docs/Web/API/FileList) from [DataTransfer](https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/files) and set to file input
   3. let file input fire a onChange event to do upload
