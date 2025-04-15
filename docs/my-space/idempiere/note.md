convention of Info (IDEMPIERE-325)

old implement extends from InfoPanel namming by Info[function]Panel example InfoPaymentPanel

new implement extends from WindowPanel namming by Info[function]Window example InfoPaymentWindow

When define a info don't input multi line for From And Where (it's ok to break line before FROM, WHERE but not before other)

Env.parseContext:

    can't use empty string as default value because can't detect case error parse and default value

    String ctxInfo = evaluatee.get_ValueAsString(ctx, token);

    if (Util.isEmpty(ctxInfo))

context

    info window

    list of selected rows id set to context by InfoPanel.ROW_ID_CTX_VARIABLE_NAME (_IWInfoIDs_Selected)

    value of items on current sekected row on info set to context by InfoPanel.ROW_CTX_VARIABLE_PREFIX[columnName] example_IWInfo_C_Invoice_ID

when a parameter in infowindow is choose, main context is n't update until do a query (why need to wait?)

Object obj

Interger intObj = (Integer)obj and int intValue= (int)obj
is diference or not?

intValue= (int)obj

=

Integer temp= (Integer)obj

intValue = temp.intValue()

so (int)obj fire NPE when obj is null

grid field default value

    https://idempiere.atlassian.net/browse/IDEMPIERE-2678

payment selection

    https://idempiere.atlassian.net/browse/IDEMPIERE-2134


ProcessParameter.restoreContext

GridField.restoreValue

GridField.backupValue

GridField.updateContext
