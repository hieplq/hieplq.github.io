```xml
<div
  sclass="@init(('grid-listView grid-listView-' += vmListView.component.columnInfos.size() ))"
    children="@bind(vmListView.component.rows)">
  
  <template name="children" var="row">
    <!-- header -->
    <nodom if="${rowStatus.first}">
      <nodom children="@bind(vmListView.component.columnInfos)">
        <template name="children" var="titleCol">
          <div sclass="cell colHead">
            <label value="@init(titleCol.title)" />
          </div>
        </template>
      </nodom>
    </nodom>
  
    <!-- detail -->
    <nodom
      children="@bind(vmListView.component.columnInfos)">
      <!-- template to generate a title/component per col -->
      <template name="children" var="col">
        <!-- group title/content -->
        <div sclass="cell detail">
          <!-- title part, show description, error message -->
          <div sclass="cell-title">
            <!-- error -->
            <label sclass="error"></label>
          </div>

          <!-- content part -->
          <div sclass="cell-content">
        
        
            <!-- label -->
            <label if="${row[col].cellType eq CellModel.LABEL_CELL}"
              value="@bind(row[col].cellType)" />
        
          </div>
        </div>
      </template>
    </nodom>
  
  </template>
</div>
```

error when parse if = `${row[col].cellType eq CellModel.LABEL_CELL}` because row is not on contect of standard EL

but not error when parse `@bind(row[col].cellType)` because mvvm binding supported inner template reference to outer

this one not work
`<label if="${colStatus.previous.current[col].cellType eq CellModel.TEXT_CELL}"`
because colStatus.previous isn't support (always return null) 
see: org.zkoss.bind.impl.AbstractForEachStatus.getPrevious

```
<nodom
      children="@bind(vmCellRender.row.annexure.columnInfos)">
```

in case vmCellRender.row is extend from Map then when resolve value it use org.zkoss.zel.MapELResolver first
so it get null and not try to resolve by other ELResolver