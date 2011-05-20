from pylons.i18n import _
from pylons import tmpl_context as c

from formencode import Schema, validators, All
from formencode.compound import Pipe
from formencode.foreach import ForEach
from formencode.api import FancyValidator
from formencode.api import Invalid
from formencode.variabledecode import NestedVariables
from ututi.model.users import User
from ututi.lib.validators import UserPasswordValidator, TranslatedEmailValidator, \
    UniqueEmail, LocationTagsValidator, PhoneNumberValidator, \
    FileUploadTypeValidator, SeparatedListValidator, URLNameValidator


class LocationForm(Schema):
    pre_validators = [NestedVariables()]
    allow_extra_fields = True
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())


class UserLocationIntegrity(FancyValidator):

    messages = {
        'duplicated': _(u"You can't choose this department."),
        }

    def validate_python(self, value, state):
        # If there are users in selected locations and this user are not current
        # user, we will show some Error.
        for user in User.get_all(c.user.username):
            if user.location == value and user.id != c.user.id:
                raise Invalid(self.message('duplicated', state), value, state)


class ProfileForm(Schema):
    """A schema for validating user profile forms."""

    pre_validators = [NestedVariables()]
    allow_extra_fields = True
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator(),
                    UserLocationIntegrity())

    fullname = validators.String(not_empty=True)
    url_name = URLNameValidator()


class BiographyForm(Schema):
    """A schema for validating user biography forms."""
    pre_validators = [NestedVariables()]
    allow_extra_fields = True
    description = validators.String(strip=True)


class PublicationsForm(Schema):
    """A schema for validating user biography forms."""
    pre_validators = [NestedVariables()]
    allow_extra_fields = True
    publications = validators.String(strip=True)


class PasswordChangeForm(Schema):
    allow_extra_fields = False

    password = UserPasswordValidator(not_empty=True)

    msg = {'empty': _(u"Please enter your password."),
           'tooShort': _(u"The password must be at least 5 symbols long.")}

    new_password = validators.String(
        min=5, not_empty=True, strip=True, messages=msg)

    repeat_password = validators.String(
        min=5, not_empty=True, strip=True, messages=msg)

    msg = {'invalid': _(u"Passwords do not match."),
           'invalidNoMatch': _(u"Passwords do not match."),
           'empty': _(u"Please enter your password.")}
    chained_validators = [validators.FieldsMatch('new_password',
                                                 'repeat_password',
                                                 messages=msg)]


class GaduGaduConfirmationNumber(validators.FormValidator):

    messages = {
        'invalid': _(u"This is not the confirmation code we sent you."),
    }

    def validate_python(self, form_dict, state):
        if not form_dict['gadugadu_confirmation_key']:
            return
        if not form_dict['confirm_gadugadu'] and not form_dict['update_contacts']:
            return
        if (form_dict['gadugadu_confirmation_key'] and
            c.user.gadugadu_uin == form_dict['gadugadu_uin'] and
            c.user.gadugadu_confirmation_key.strip() == form_dict['gadugadu_confirmation_key']):
            return

        raise Invalid(self.message('invalid', state),
                      form_dict, state,
                      error_dict={'gadugadu_confirmation_key': Invalid(self.message('invalid', state), form_dict, state)})


class PhoneConfirmationNumber(validators.FormValidator):

    messages = {
        'invalid': _(u"This is not the confirmation code we sent you."),
    }

    def validate_python(self, form_dict, state):
        if not form_dict['phone_confirmation_key']:
            return
        if not form_dict['confirm_phone'] and not form_dict['update_contacts']:
            return
        if (form_dict['phone_confirmation_key'] and
            c.user.phone_number == form_dict['phone_number'] and
            c.user.phone_confirmation_key.strip() == form_dict['phone_confirmation_key']):
            return

        raise Invalid(self.message('invalid', state),
                      form_dict, state,
                      error_dict={'phone_confirmation_key': Invalid(self.message('invalid', state), form_dict, state)})


class PhoneForm(Schema):
    allow_extra_fields = True
    phone_number = PhoneNumberValidator()


class PhoneConfirmationForm(Schema):
    allow_extra_fields = True
    phone_confirmation_key = validators.String()


class ContactForm(Schema):

    allow_extra_fields = True

    msg = {'non_unique': _(u"This email is already in use.")}
    email = All(TranslatedEmailValidator(not_empty=True, strip=True),
                UniqueEmail(messages=msg, strip=True))

    site_url = validators.URL()
    gadugadu_uin = validators.Int()
    phone_number = PhoneNumberValidator()

    gadugadu_get_news = validators.StringBool(if_missing=False)

    gadugadu_confirmation_key = validators.String()
    phone_confirmation_key = validators.String()

    confirm_email = validators.Bool()
    confirm_gadugadu = validators.Bool()
    confirm_phone = validators.Bool()

    resend_phone_code = validators.Bool()
    resend_gadugadu_code = validators.Bool()

    update_contacts = validators.Bool()

    chained_validators = [GaduGaduConfirmationNumber(),
                          PhoneConfirmationNumber()]


class LogoUpload(Schema):
    """A schema for validating logo uploads."""
    allow_extra_fields = True
    messages = {
       'empty': _(u"Please select your photo."),
       'bad_type': _(u"Please upload JPEG, PNG or GIF image.")
    }
    logo = FileUploadTypeValidator(not_empty=True,
                                   allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'),
                                   messages=messages)


class HideElementForm(Schema):
     """Ajax submit validator to hide welcome screen widgets."""
     allow_extra_fields = False
     type = validators.OneOf(['suggest_create_group', 'suggest_watch_subject', 'suggest_enter_phone'])


class StudentGroupForm(Schema):
    """Validating student group creation."""
    allow_extra_fields = False
    title = validators.String(not_empty=True)
    email = TranslatedEmailValidator(not_empty=True)


class StudentGroupMessageForm(Schema):
    allow_extra_fields = True

    subject = validators.String()
    message = validators.String()


class StudentGroupDeleteForm(Schema):
    allow_extra_fields = True
    group_id = validators.Int()


class MultiRcptEmailForm(Schema):
    allow_extra_fields = True

    sender = validators.Email(not_empty=True)
    msg = {'empty': _(u"Please enter email subject.")}
    subject = validators.String(not_empty=True, messages=msg)
    msg = {'empty': _(u"Message can not be empty.")}
    message = validators.String(not_empty=True, messages=msg)
    msg = {'empty': _(u"Please enter at least one email address.")}
    recipients = Pipe(validators.String(not_empty=True, messages=msg),
                      SeparatedListValidator(separators=',', whitespace=False),
                      ForEach(validators.Email(not_empty=True)))


class FriendsInvitationForm(Schema):
    """A schema for validating ututi recommendation submissions"""
    allow_extra_fields = True
    recipients = validators.UnicodeString(not_empty=False)
    message = validators.UnicodeString(not_empty=False)


class FriendsInvitationJSForm(Schema):
    """A schema for validating ututi recommendation submissions"""
    allow_extra_fields = True
    message = validators.UnicodeString(not_empty=False)
    msg = {'empty': _(u"Please enter at least one email address.")}
    recipients = Pipe(validators.String(not_empty=True, messages=msg),
                      SeparatedListValidator(separators=',', whitespace=False),
                      ForEach(validators.Email(not_empty=True)))

