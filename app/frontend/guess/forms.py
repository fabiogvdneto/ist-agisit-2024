from django import forms

class GuessForm(forms.Form):
    value = forms.IntegerField(label='Enter a number')
