@AdminConfig =
    name: Config.name
    collections: {}
        # CollectionName: {
        #     icon: 'pencil'
        #     omitFields: ['createdAt']
        #     tableColumns: [
        #         {label: 'Name', name: 'name'}
        #         {label: 'Url', name: 'url'}
        #         {label: 'Updated At', name: 'updatedAt'}
        #     ]
        # }
    autoForm: 
        omitFields: ['createdAt', 'updatedAt']
    dashboard:
        homeUrl: '/'
