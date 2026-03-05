def rename_columns_russian(*args):
    dict = {
        "Plaster" : "Шпахтель",
        "Paint" : "Краска",
        "CornersH" : "Углы  гор.",
        "CornersV" : "Углы вер.",
        "Panels" : "Плинтусы",
        "Old" : "Каям",
        "Male" : "Мале",
        "Profiles" : "Профили"
    }

    doc = XSCRIPTCONTEXT.getDocument()
    sheet = doc.CurrentController.ActiveSheet

    for key,value in dict.items():
        descriptor = sheet.createSearchDescriptor()
        descriptor.SearchString = key

        found = sheet.findFirst(descriptor)

        while found:
            found.String = found.String.replace(key, value)
            found = sheet.findNext(found, descriptor)
