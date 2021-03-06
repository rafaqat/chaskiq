require "rails_helper"

module Chaskiq
  RSpec.describe CampaignMailer, type: :mailer do

    let(:template){ FactoryGirl.create(:chaskiq_template) }
    let(:list){ FactoryGirl.create(:chaskiq_list) }
    let(:subscriber){
      list.create_subscriber FactoryGirl.attributes_for(:chaskiq_subscriber)
    }
    let(:campaign){ FactoryGirl.create(:chaskiq_campaign, template: template, list: list) }
    let(:template_html){ "<p>{{name}}</p>"}
    let(:premailer_template){"<p>
      {{name}} {{last_name}} {{email}} {{campaign_url}}
      {{campaign_subscribe}} {{campaign_unsubscribe}}
      {{campaign_description}} {{track_image_url}}
      this is the template</p>"}

    before do
      allow_any_instance_of(Chaskiq::Campaign).to receive(:premailer).and_return(premailer_template)
      allow_any_instance_of(Chaskiq::Campaign).to receive(:html_content).and_return(template_html)
      Chaskiq::CampaignMailer.newsletter(campaign, subscriber.subscriptions.first).deliver_now
    end

    it "pass subscriber attributes to template" do
      at = campaign.attributes_for_mailer(subscriber)
      expect(last_email.subject).to_not be_blank
      expect(last_email.body).to include(subscriber.name)
      expect(last_email.body).to include(subscriber.last_name)
      expect(last_email.body).to include(subscriber.email)

      expect(last_email.body).to include(at[:campaign_url])
      expect(last_email.body).to include(at[:campaign_unsubscribe])
      expect(last_email.body).to include(at[:campaign_subscribe])
      expect(last_email.body).to include(at[:campaign_description])
      expect(last_email.body).to include(at[:track_image_url])
    end

    it "should deliver with open.gif" do
      expect(last_email.body).to include("open.gif")
    end


  end
end
