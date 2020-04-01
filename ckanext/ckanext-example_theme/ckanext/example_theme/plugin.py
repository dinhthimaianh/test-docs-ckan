import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
import requests
from flask import Flask, request, redirect, jsonify
import ckan.logic as logic
import ckan.authz as authz
import ckan.logic.auth as logic_auth
import json
from ckan.common import  config


def group_create(context, data_dict=None):
    return {'success': False, 'msg': 'No one is allowed to create groups'}


def check_auth(context, data_dict=None):
    user = context.get('user')
    ignore_auth = context.get('ignore_auth')
    if ignore_auth or (user and authz.is_sysadmin(user)):
    	return True
    else:
        return False

  
#POST data to API
def uploadFileToCloud(context,data_dict=None):
    #Call check_auth to check permission of user
    test = check_auth(context,data_dict)
    #if test is True => POST data to cloud
    #if test is Fasle: return None
    if test ==  True:
        file = request.files['data']
        fileName = file.filename
        #Get url from development.ini
        url = config.get('url_cloud','')
       
        #Send data to cloud
        payload = {}
        files = [('data',  (fileName, file, 'application/octet-stream'))]
        headers = {
        }
        response = requests.request("POST", url, headers=headers, data = payload, files = files)
        #Get response from cloud
        response_api = response.text
        data = json.loads(response_api)
        data_dict = data['file_path']
        url_response = config.get('url_get_file_from_cloud','')
        data_dict =  url_response + data_dict
        return data_dict
    else :
        return None

def most_popular_groups():

    # datasets.
    #Get six groups
        groups = toolkit.get_action('group_list')(
        data_dict={'sort': 'package_count desc','all_fields': True})
        groups = groups[:7]
        return groups

class Example_ThemePlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic', 'example_theme')

    plugins.implements(plugins.ITemplateHelpers)
    

    def get_helpers(self):
        '''Register the most_popular_groups() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'example_theme_most_popular_groups': most_popular_groups}
    
   
    plugins.implements(plugins.interfaces.IActions)

    
    def get_actions(self):
    # Registers the custom API method defined above
        return {'uploadFileToCloud': uploadFileToCloud}

    plugins.implements(plugins.IAuthFunctions)

    def get_auth_functions(self):
        return {'group_create': group_create}
 
    def get_auth_functions(self):
        return {'check_auth': check_auth}

    

    