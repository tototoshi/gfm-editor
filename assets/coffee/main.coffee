App = {}

App.mediator = _.extend({}, Backbone.Events)

App.IndexModel = Backbone.Model.extend
    searchText: ''

App.NoteModel = Backbone.Model.extend
    urlRoot: '/api/note'

App.NoteCollection = Backbone.Collection.extend
    url: '/api/notes'
    model: App.NoteModel

App.SearchOrNewView = Backbone.View.extend
    render: ->
        return this
    searchOrNew: ->
        text = this.$el.val()
        this.model.set('text', text)
        App.mediator.trigger('search-text-updated', text)
    focus: ->
        this.$el.show()
        this.$el.focus()
    hide: ->
        this.$el.val('')
        this.$el.hide()
    events:
        "input": "searchOrNew"
        "focusin": "searchOrNew"
        "focusout": "hide"

App.IndexView = Backbone.View.extend
    initialize: (options) ->
        this.listenTo(this.collection, 'sync', this.render)
        this.listenTo(this.model, 'change', this.search)
        this.collection.fetch()
    search: ->
        searchText = this.model.get('text')
        
        if searchText.trim().length < 0
            _.each @items, (item) -> item.$el.show()
        else
            firstMatch = null
            _.each @items, (item) =>
                itemTitle = item.model.get('title')
                if itemTitle.toLowerCase().indexOf(searchText.toLowerCase()) >= 0
                    if firstMatch == null
                        firstMatch = item
                    item.$el.show()
                else
                    item.$el.hide()

        if firstMatch != null
            this.selectNote firstMatch.model.id
        else
            App.mediator.trigger('new-note')
    selectNote: (id) ->
        match = _.filter @items, (item) -> id == item.model.id
        unmatch = _.filter @items, (item) -> id != item.model.id
        _.each match, (i) -> i.select()
        _.each unmatch, (i) -> i.unselect()
    selectPrevious: ->
        visibles = _.filter @items, (item) =>
            item.$el.css('display') != 'none'
        if visibles.length == 0
            return
        currentSelected = this.getCurrentSelected()
        if currentSelected.length == 0
            return
        currentSelectedId = currentSelected[0].model.id
        currentIndex = 0
        alreadyFind = false
        _.each visibles, (visible) ->
            if ! alreadyFind
                if visible.model.id == currentSelectedId
                    alreadyFind = true
                else
                    currentIndex++
        if currentIndex > 0
            this.selectNote visibles[currentIndex - 1].model.id
    selectNext: ->
        visibles = _.filter @items, (item) =>
            item.$el.css('display') != 'none'
        if visibles.length == 0
            return
        currentSelected = this.getCurrentSelected()
        if currentSelected.length == 0
            this.selectNote visibles[0].model.id
            return
        currentSelectedId = currentSelected[0].model.id
        currentIndex = 0
        alreadyFind = false
        _.each visibles, (visible) ->
            if ! alreadyFind
                if visible.model.id == currentSelectedId
                    alreadyFind = true
                else
                    currentIndex++
        if visibles.length > currentIndex + 1
            this.selectNote visibles[currentIndex + 1].model.id
    changeTitle: (id, title) ->
        _.each @items, (item) ->
            if item.model.id == id
                item.model.set('title', title)    
    getCurrentSelected: ->
        _.filter @items, (item) ->
            item.$el.hasClass('selected')
    deleteCurrentSelected: ->
        selected = this.getCurrentSelected()[0]
        if window.confirm('Are you sure to delete this note?')
            selected.model.destroy
                success: (model, response) =>
                    App.mediator.trigger('notify-deleted')
                    App.mediator.trigger('new-note')
                    this.collection.fetch()
                error: (model, response) ->
                    App.mediator.trigger('notify-error')
    render: ->
        this.$el.empty()
        @items = []
        _.each(this.collection.models, (item) =>
            item = new App.IndexItemView 
                model: item
                el: $('<li>')
            @items.push item
            this.$el.append(item.render().el))
        return this
   
App.IndexItemView = Backbone.View.extend
    render: ->
        this.$el.text(this.model.get('title'))
        this.listenTo(this.model, 'change', this.updateTitle)
        return this
    select: ->
        this.$el.addClass('selected')
        App.mediator.trigger('refresh-note', this.model.id)
    unselect: ->
        this.$el.removeClass('selected')
    updateTitle: ->
        this.$el.text(this.model.get('title'))
    triggerSelect: ->
        App.mediator.trigger('select-note', this.model.id)
    events:
        "click": "triggerSelect"
        
App.DocumentView = Backbone.View.extend
    shortcuts: (e) ->
        if ! $(document.activeElement).is("textarea") && e.keyCode == 46
            e.preventDefault()
            App.mediator.trigger('delete-note')       
        else if ! $(document.activeElement).is("textarea") && e.keyCode == 13 
            e.preventDefault()
            App.mediator.trigger('focus-editor')       
        else if ! $(document.activeElement).is("textarea") && e.keyCode == 38
            App.mediator.trigger('select-previous')
        else if ! $(document.activeElement).is("textarea") && e.keyCode == 40
            App.mediator.trigger('select-next')
        else if e.metaKey && e.keyCode == 37
            e.preventDefault()
            App.mediator.trigger('show-preview')
        else if e.metaKey && e.keyCode == 39
            e.preventDefault()
            App.mediator.trigger('hide-preview')
        else if e.keyCode == 27
            e.preventDefault()
            App.mediator.trigger('focus-search-or-new')       
    events:
        "keydown": "shortcuts"    


App.EditorView = Backbone.View.extend
    initialize: ->
        if ! this.model.isNew()
            this.model.fetch()

        this.render()
        this.listenTo(this.model, 'change', this.render)
        this.listenTo(this.model, 'destroy', this.clear)
        this.listenTo(this.model, 'reset', this.reset)
    focus: ->
        this.$el.focus()
        if this.model.isNew() and this.$el.val().trim() != ''
            this.updateNote()
    clear: ->
        this.$el.val('')
        $('#view').html('')
    showPreview: ->
        this.$el.parent('#editor').removeClass('col-xs-10').addClass('col-xs-5')
        $('#view').show()
    hidePreview: ->
        this.$el.parent('#editor').removeClass('col-xs-5').addClass('col-xs-10')
        $('#view').hide()
    reset: ->
        this.$el.empty()
    newNoteWithSearchText: (text) ->
        if this.model.isNew()
            $('#view').html('')
            this.$el.val(text)
    newNote: ->
        if this.model.id
            this.model.clear()
            this.$el.val('')
            $('#view').html('')
    fetchNote: (id) ->
        this.model.set('id', id)
        this.model.fetch()
    render: ->
        isNotEmpty = (line) -> line.trim().length != 0
        old_lines = _.filter($('#view').text().split("\n"), isNotEmpty)
        this.$el.val(this.model.get('raw'))
        $.post(
            '/api/render'
            { raw: this.$el.val() }
            (data, textStatus, jqXHR) ->
                $('#view').html(data)
                lines = _.filter($('#view').text().split("\n"), isNotEmpty)
                same_except_last_line = old_lines.slice(0, old_lines.length - 1).join("\n") == lines.slice(0, old_lines.length - 1).join("\n") 
                if same_except_last_line and old_lines[old_lines.length - 1] != lines[lines.length - 1]
                    $('#view').animate({ scrollTop: $('#view').get(0).scrollHeight }, 500)
        )
        return this
    updateNote: ->
        raw = this.$el.val()
        title = raw.replace(/^[#\s]*|\s*$/g, "").split("\n")[0]
        App.mediator.trigger('title-change', this.model.id, title)
        this.model.save {title, title, raw: raw},
            success: (model, response) =>
                App.mediator.trigger('notify-saved')
                this.collection.fetch()
            error: (model, response) ->
                App.mediator.trigger('notify-error')
    debounceUpdateNote:
        _.debounce(
            -> this.updateNote(),
            500
        )
    events:
        "input": "debounceUpdateNote"
        "click #delete": "delete"

App.NotifView = Backbone.View.extend
    notifySaved: ->
        notif
            msg: "Saved"
            type: "success"
            position: "right"
            height: 50
            width: 100
    notifyError: ->
        notif
            msg: "Oops!"
            type: "error"
            position: "right"
            height: 50
            width: 100
    notifyDeleted: ->
        notif
            msg: "Deleted"
            type: "success"
            position: "right"
            height: 50
            width: 100

App.AppView = Backbone.View.extend {}

$ ->
    appView = new App.AppView
        el: $(window)

    documentView = new App.DocumentView
        el: $(document)

    indexModel = new App.IndexModel

    note = new App.NoteModel

    noteCollection = new App.NoteCollection

    editorView = new App.EditorView
        model: note
        collection: noteCollection
        el: $('textarea')

    searchOrNewView = new App.SearchOrNewView
        el: $('#search-or-new')
        model: indexModel

    indexView = new App.IndexView
        el: $('#index > ul')
        model: indexModel
        collection: noteCollection

    notifView = new App.NotifView

    App.mediator.on('title-change', _.bind(indexView.changeTitle, indexView))
    App.mediator.on('notify-saved', _.bind(notifView.notifySaved, notifView))
    App.mediator.on('notify-error', _.bind(notifView.notifyError, notifView))
    App.mediator.on('notify-deleted', _.bind(notifView.notifyDeleted, notifView))
    App.mediator.on('focus-search-or-new', _.bind(searchOrNewView.focus, searchOrNewView))
    App.mediator.on('hide-search-or-new', _.bind(searchOrNewView.hide, searchOrNewView))
    App.mediator.on('focus-editor', _.bind(editorView.focus, editorView))
    App.mediator.on('select-note', _.bind(indexView.selectNote, indexView))
    App.mediator.on('select-previous', _.bind(indexView.selectPrevious, indexView))
    App.mediator.on('select-next', _.bind(indexView.selectNext, indexView))
    App.mediator.on('refresh-note', _.bind(editorView.fetchNote, editorView))
    App.mediator.on('search-text-updated', _.bind(editorView.newNoteWithSearchText, editorView))
    App.mediator.on('new-note', _.bind(editorView.newNote, editorView))
    App.mediator.on('hide-preview', _.bind(editorView.hidePreview, editorView))
    App.mediator.on('show-preview', _.bind(editorView.showPreview, editorView))
    App.mediator.on('delete-note', _.bind(indexView.deleteCurrentSelected, indexView))

    Backbone.history.start();

