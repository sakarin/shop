Deface::Override.new(:virtual_path => "spree/admin/configurations/index",
                     :name => "faq_admin_tab",
                     :insert_after => "[data-hook='admin_configurations_menu'], #admin_configurations_menu[data-hook]",
                     :disabled => false,
                     :text => "<tr>
<td><%= link_to t('question_categories'), admin_question_categories_path %></td>
		<td><%= t('question_categories_description') %></td>
	</tr>")




