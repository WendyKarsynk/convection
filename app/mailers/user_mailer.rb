# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper :url, :submissions, :offers

  def submission_receipt(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-receipt',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[submission_receipt],
            unique_args: {
              submission_id: submission.id
            }
    mail(
      to: user.email,
      subject: 'Thank you for submitting your artwork to Artsy',
      bcc: Convection.config.bcc_email_address
    )
  end

  def first_upload_reminder(submission:, user:)
    @submission = submission
    @user = user
    @utm_params =
      utm_params(
        source: 'drip-consignment-reminder-e01',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[first_upload_reminder],
            unique_args: {
              submission_id: submission.id
            }
    mail to: user.email, subject: "You're Almost Done"
  end

  def second_upload_reminder(submission:, user:)
    @submission = submission
    @user = user
    @utm_params =
      utm_params(
        source: 'drip-consignment-reminder-e02-v2',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[second_upload_reminder],
            unique_args: {
              submission_id: submission.id
            }
    mail to: user.email,
         subject: 'Artsy Consignments - complete your submission'
  end

  def submission_approved(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-approved',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[submission_approved],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: user.email, subject: 'Artsy Approved Submission | Next Steps')
  end

  def artist_submission_rejected(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-rejected',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[artist_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: user.email, subject: 'An update about your submission')
  end

  def fake_submission_rejected(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-rejected',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[fake_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: user.email, subject: 'Artsy Submission')
  end

  def nsv_bsv_submission_rejected(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-rejected',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[nsv_bsv_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: user.email, subject: 'An update about your submission')
  end

  def other_submission_rejected(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist
    @utm_params =
      utm_params(
        source: 'consignment-rejected',
        campaign: 'consignment-complete'
      )

    smtpapi category: %w[other_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    mail(to: user.email, subject: 'An update about your submission')
  end

  def offer(offer:, artist:, user:)
    @offer = offer
    @submission = offer.submission
    @artist = artist
    @user = user
    @utm_params =
      utm_params(source: 'consignment-offer', campaign: 'consignment-offer')

    smtpapi category: %w[offer], unique_args: { offer_id: offer.id }
    mail(to: user.email, subject: 'An Offer for your Artwork')
  end
end
